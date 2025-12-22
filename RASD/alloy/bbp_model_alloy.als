module BestBikePaths

// ============================================================================
// SIGNATURES - Core Domain Entities
// ============================================================================

// --- Users ---
abstract sig User {}

sig RegisteredUser extends User {
    userId: one Int,
    email: one Int,  // Simplified as Int for modeling
    usedDevice: lone MobileDevice,
    createdPathInfos: set PathInfo,
    ownedTrips: set Trip,
    reviewedData: set AcquiredPathData
}

// --- Mobile Device and Sensors ---
sig MobileDevice {
    deviceId: one Int,
    sensorsEnabled: one Bool,
    autoDetectionEnabled: one Bool,
    GPSEnabled: one Bool,
    producedData: set AcquiredPathData
}

// --- Acquisition Mode ---
abstract sig AcquisitionMode {}
one sig MANUAL_RECORDING extends AcquisitionMode {}
one sig AUTOMATIC_DETECTION extends AcquisitionMode {}

// --- Path Status ---
abstract sig PathStatus {}
one sig OPTIMAL extends PathStatus {}
one sig MEDIUM extends PathStatus {}
one sig SUFFICIENT extends PathStatus {}
one sig REQUIRES_MAINTENANCE extends PathStatus {}

// --- Obstacle Type ---
abstract sig ObstacleType {}
one sig POTHOLE extends ObstacleType {}
one sig DEBRIS extends ObstacleType {}
one sig CONSTRUCTION extends ObstacleType {}
one sig OTHER extends ObstacleType {}

// --- Acquired Path Data (Raw Data from Device) ---
sig AcquiredPathData {
    acquisitionId: one Int,
    collectedBy: one RegisteredUser,
    mode: one AcquisitionMode,
    detectedObstacles: set Obstacle,  // Unconfirmed obstacles
    suggestedStatus: one PathStatus,
    reviewedTo: lone PathInfo  // Can be reviewed to at most one PathInfo
}

// --- Path Info (Verified and Corrected Data) ---
sig PathInfo {
    pathInfoId: one Int,
    owner: one RegisteredUser,
    isPublished: one Bool,
    status: one PathStatus,
    segments: some PathSegment,  // At least one segment
    savedAsTrip: lone Trip,  // Can generate at most one Trip
    publishedAsBikePath: lone BikePath  // Can be published at most once
}

// --- Trip (Personal Statistics) ---
sig Trip {
    tripId: one Int,
    belongsTo: one RegisteredUser,
    sourcePathInfo: one PathInfo,
    distance: one Int,
    avgSpeed: one Int,
    weatherData: lone WeatherData,
    publishedAsBikePath: lone BikePath  // Can be published as BikePath
}

// --- Bike Path (Community Shared Information) ---
sig BikePath {
    bikePathId: one Int,
    sourcePathInfo: one PathInfo,
    score: one Int,
    contributor: one RegisteredUser,
    displayedSegments: some PathSegment
}

// --- Path Segment (Street Section) ---
sig PathSegment {
    segmentId: one Int,
    streetName: one Int,  // Simplified as Int
    obstacles: set Obstacle  // Can have zero or more obstacles
}

// --- Obstacle (Confirmed in PathInfo) ---
sig Obstacle {
    obstacleId: one Int,
    obstacleType: one ObstacleType,
    confirmed: one Bool,
    reportedAt: one Int  // Timestamp as Int
}

// --- Weather Data ---
sig WeatherData {
    temperature: one Int,
    windSpeed: one Int
}

// --- Boolean Type ---
abstract sig Bool {}
one sig True extends Bool {}
one sig False extends Bool {}

// ============================================================================
// FACTS - Domain Constraints
// ============================================================================

// --- Fact 1: Unique IDs ---
fact UniqueIdentifiers {
    // Each RegisteredUser has unique userId
    all disj u1, u2: RegisteredUser | u1.userId != u2.userId
    
    // Each MobileDevice has unique deviceId
    all disj d1, d2: MobileDevice | d1.deviceId != d2.deviceId
    
    // Each AcquiredPathData has unique acquisitionId
    all disj a1, a2: AcquiredPathData | a1.acquisitionId != a2.acquisitionId
    
    // Each PathInfo has unique pathInfoId
    all disj p1, p2: PathInfo | p1.pathInfoId != p2.pathInfoId
    
    // Each Trip has unique tripId
    all disj t1, t2: Trip | t1.tripId != t2.tripId
    
    // Each BikePath has unique bikePathId
    all disj b1, b2: BikePath | b1.bikePathId != b2.bikePathId
    
    // Each PathSegment has unique segmentId
    all disj s1, s2: PathSegment | s1.segmentId != s2.segmentId
    
    // Each Obstacle has unique obstacleId
    all disj o1, o2: Obstacle | o1.obstacleId != o2.obstacleId
}

// --- Fact 2: Bidirectional Consistency ---
fact BidirectionalConsistency {
    // RegisteredUser.createdPathInfos <-> PathInfo.owner
    all u: RegisteredUser, p: PathInfo |
        p in u.createdPathInfos iff u = p.owner
    
    // RegisteredUser.ownedTrips <-> Trip.belongsTo
    all u: RegisteredUser, t: Trip |
        t in u.ownedTrips iff u = t.belongsTo
    
    // RegisteredUser.reviewedData <-> AcquiredPathData.collectedBy
    all u: RegisteredUser, a: AcquiredPathData |
        a in u.reviewedData iff u = a.collectedBy
    
    // If user uses a device, device produces data for that user
    all u: RegisteredUser, d: MobileDevice, a: AcquiredPathData |
        (u.usedDevice = d and a in d.producedData) implies a.collectedBy = u
}

// --- Fact 3: PathInfo Constraints ---
fact PathInfoConstraints {
    // PathInfo can generate at most ONE Trip
    all p: PathInfo | lone p.savedAsTrip
    
    // PathInfo can be published as at most ONE BikePath
    all p: PathInfo | lone p.publishedAsBikePath
    
    // If PathInfo has a Trip, the Trip must reference back to PathInfo
    all p: PathInfo, t: Trip |
        t = p.savedAsTrip implies t.sourcePathInfo = p
    
    // If PathInfo has a BikePath, the BikePath must reference back to PathInfo
    all p: PathInfo, b: BikePath |
        b = p.publishedAsBikePath implies b.sourcePathInfo = p
    
    // PathInfo must have at least one PathSegment
    all p: PathInfo | some p.segments
    
    // All obstacles in PathInfo segments must be confirmed
    all p: PathInfo, s: PathSegment, o: Obstacle |
        (s in p.segments and o in s.obstacles) implies o.confirmed = True
    
    // Published PathInfo must have isPublished = True
    all p: PathInfo |
        (some p.publishedAsBikePath) implies p.isPublished = True
    
    // If not published, isPublished must be False
    all p: PathInfo |
        (no p.publishedAsBikePath) implies p.isPublished = False
}

// --- Fact 4: Trip Constraints ---
fact TripConstraints {
    // Every Trip must belong to a RegisteredUser
    all t: Trip | one t.belongsTo
    
    // Every Trip must have a sourcePathInfo
    all t: Trip | one t.sourcePathInfo
    
    // Trip can be published as at most ONE BikePath
    all t: Trip | lone t.publishedAsBikePath
    
    // Trip owner must match PathInfo owner
    all t: Trip | t.belongsTo = t.sourcePathInfo.owner
    
    // If Trip is published as BikePath, the BikePath must be based on Trip's PathInfo
    all t: Trip, b: BikePath |
        b = t.publishedAsBikePath implies b.sourcePathInfo = t.sourcePathInfo
}

// --- Fact 5: BikePath Constraints ---
fact BikePathConstraints {
    // Every BikePath must have a sourcePathInfo
    all b: BikePath | one b.sourcePathInfo
    
    // BikePath must display at least one PathSegment
    all b: BikePath | some b.displayedSegments
    
    // BikePath displayed segments must be from sourcePathInfo
    all b: BikePath | b.displayedSegments in b.sourcePathInfo.segments
    
    // BikePath contributor must be the owner of sourcePathInfo
    all b: BikePath | b.contributor = b.sourcePathInfo.owner
    
    // If BikePath exists, its sourcePathInfo must be published
    all b: BikePath | b.sourcePathInfo.isPublished = True
}

// --- Fact 6: AcquiredPathData Lifecycle ---
fact AcquiredPathDataLifecycle {
    // AcquiredPathData can be reviewed to at most ONE PathInfo
    all a: AcquiredPathData | lone a.reviewedTo
    
    // If AcquiredPathData is reviewed, the PathInfo owner must be the collector
    all a: AcquiredPathData, p: PathInfo |
        p = a.reviewedTo implies p.owner = a.collectedBy
    
    // Obstacles in AcquiredPathData that are NOT YET reviewed are unconfirmed
    // (Once reviewed and moved to PathInfo, they become confirmed)
    all a: AcquiredPathData, o: Obstacle |
        (o in a.detectedObstacles and no a.reviewedTo) implies o.confirmed = False
}

// --- Fact 7: Obstacle Confirmation ---
fact ObstacleConfirmation {
    // Obstacles in PathInfo segments must be confirmed
    all p: PathInfo, s: PathSegment, o: Obstacle |
        (s in p.segments and o in s.obstacles) implies o.confirmed = True
    
    // Obstacles in AcquiredPathData that haven't been reviewed are unconfirmed
    all a: AcquiredPathData, o: Obstacle |
        (o in a.detectedObstacles and no a.reviewedTo) implies o.confirmed = False
}

// --- Fact 8: No Orphan Entities ---
fact NoOrphans {
    // Every PathInfo must be created by a RegisteredUser
    all p: PathInfo | some u: RegisteredUser | p in u.createdPathInfos
    
    // Every Trip must be owned by a RegisteredUser
    all t: Trip | some u: RegisteredUser | t in u.ownedTrips
    
    // Every AcquiredPathData must be reviewed by a RegisteredUser
    all a: AcquiredPathData | some u: RegisteredUser | a in u.reviewedData
    
    // Every BikePath must have a contributor
    all b: BikePath | some u: RegisteredUser | b.contributor = u
}

// ============================================================================
// PREDICATES - Operations and State Transitions
// ============================================================================

// --- Predicate: Review AcquiredPathData to create PathInfo ---
pred reviewAndCorrectData[a: AcquiredPathData, p: PathInfo] {
    // Relationship exists
    a.reviewedTo = p
    p.owner = a.collectedBy
}

// --- Predicate: Save PathInfo as Trip ---
pred savePathInfoAsTrip[p: PathInfo, t: Trip] {
    // Relationship exists
    p.savedAsTrip = t
    t.sourcePathInfo = p
    t.belongsTo = p.owner
}

// --- Predicate: Publish PathInfo as BikePath ---
pred publishPathInfoAsBikePath[p: PathInfo, b: BikePath] {
    // Relationship exists
    p.publishedAsBikePath = b
    p.isPublished = True
    b.sourcePathInfo = p
    b.contributor = p.owner
}

// --- Predicate: Publish Trip as BikePath ---
pred publishTripAsBikePath[t: Trip, b: BikePath] {
    // Relationship exists
    t.publishedAsBikePath = b
    b.sourcePathInfo = t.sourcePathInfo
    b.contributor = t.belongsTo
}

// --- Predicate: Manual Recording Workflow ---
pred manualRecordingWorkflow[u: RegisteredUser, d: MobileDevice, a: AcquiredPathData] {
    // Scenario structure
    u.usedDevice = d
    a in d.producedData
    a.mode = MANUAL_RECORDING
    a.collectedBy = u
}

// --- Predicate: Automatic Detection Workflow ---
pred automaticDetectionWorkflow[u: RegisteredUser, d: MobileDevice, a: AcquiredPathData] {
    // Scenario structure
    u.usedDevice = d
    d.autoDetectionEnabled = True
    a in d.producedData
    a.mode = AUTOMATIC_DETECTION
    a.collectedBy = u
}

// --- Predicate: Complete Publication Flow (PathInfo → BikePath) ---
pred completePublicationFlow[u: RegisteredUser, a: AcquiredPathData, p: PathInfo, b: BikePath] {
    // Step 1: Review AcquiredPathData
    reviewAndCorrectData[a, p]
    
    // Step 2: Publish PathInfo as BikePath
    publishPathInfoAsBikePath[p, b]
    
    // User is the owner
    u = p.owner
    u = b.contributor
}

// --- Predicate: Complete Trip Flow (PathInfo → Trip → BikePath) ---
pred completeTripFlow[u: RegisteredUser, a: AcquiredPathData, p: PathInfo, t: Trip, b: BikePath] {
    // Step 1: Review AcquiredPathData
    reviewAndCorrectData[a, p]
    
    // Step 2: Save as Trip
    savePathInfoAsTrip[p, t]
    
    // Step 3: Publish Trip as BikePath
    publishTripAsBikePath[t, b]
    
    // User is the owner
    u = p.owner
    u = t.belongsTo
    u = b.contributor
}

// ============================================================================
// ASSERTIONS - Verification Properties
// ============================================================================

// --- Assert 1: PathInfo can generate at most one Trip ---
assert PathInfoGeneratesAtMostOneTrip {
    all p: PathInfo | lone p.savedAsTrip
}

// --- Assert 2: PathInfo can be published at most once ---
assert PathInfoPublishedAtMostOnce {
    all p: PathInfo | lone p.publishedAsBikePath
}

// --- Assert 3: Trip published as BikePath uses sourcePathInfo ---
assert TripPublicationUsesSourcePathInfo {
    all t: Trip, b: BikePath |
        b = t.publishedAsBikePath implies b.sourcePathInfo = t.sourcePathInfo
}

// --- Assert 4: All obstacles in PathInfo are confirmed ---
assert PathInfoObstaclesAreConfirmed {
    all p: PathInfo, s: PathSegment, o: Obstacle |
        (s in p.segments and o in s.obstacles) implies o.confirmed = True
}

// --- Assert 5: PathInfo must have at least one segment ---
assert PathInfoHasSegments {
    all p: PathInfo | some p.segments
}

// --- Assert 6: AcquiredPathData reviewed before becoming PathInfo ---
// NOTE: This assertion is NOT valid for our domain because PathInfo can also be created manually
// assert AcquiredDataReviewedBeforePathInfo {
//     all p: PathInfo | some a: AcquiredPathData | a.reviewedTo = p
// }

// --- Assert 6 (Revised): PathInfo from AcquiredPathData must have been reviewed ---
assert ReviewedPathInfoHasAcquiredData {
    all p: PathInfo, a: AcquiredPathData |
        a.reviewedTo = p implies p.owner = a.collectedBy
}

// --- Assert 7: Published BikePath has isPublished = True ---
assert PublishedBikePathHasFlag {
    all b: BikePath | b.sourcePathInfo.isPublished = True
}

// --- Assert 8: Trip owner matches PathInfo owner ---
assert TripOwnerMatchesPathInfoOwner {
    all t: Trip | t.belongsTo = t.sourcePathInfo.owner
}

// --- Assert 9: BikePath contributor matches PathInfo owner ---
assert BikePathContributorMatchesPathInfoOwner {
    all b: BikePath | b.contributor = b.sourcePathInfo.owner
}


// ============================================================================
// COMMANDS - Example Scenarios
// ============================================================================

// --- Show a basic scenario with all entities ---
pred showBasicScenario {
    some RegisteredUser
    some MobileDevice
    some AcquiredPathData
    some PathInfo
    some Trip
    some BikePath
    some PathSegment
    some Obstacle
}

// --- Show manual recording workflow ---
pred showManualRecording {
    some u: RegisteredUser, d: MobileDevice, a: AcquiredPathData |
        manualRecordingWorkflow[u, d, a]
}

// --- Show automatic detection workflow ---
pred showAutomaticDetection {
    some u: RegisteredUser, d: MobileDevice, a: AcquiredPathData |
        automaticDetectionWorkflow[u, d, a]
}

// --- Show complete publication flow ---
pred showPublicationFlow {
    some u: RegisteredUser, a: AcquiredPathData, p: PathInfo, b: BikePath |
        completePublicationFlow[u, a, p, b]
}

// --- Show complete trip flow ---
pred showTripFlow {
    some u: RegisteredUser, a: AcquiredPathData, p: PathInfo, t: Trip, b: BikePath |
        completeTripFlow[u, a, p, t, b]
}

// --- Run commands ---
run showBasicScenario for 5
run showManualRecording for 5
run showAutomaticDetection for 5
run showPublicationFlow for 5
run showTripFlow for 5

// --- Check assertions ---
check PathInfoGeneratesAtMostOneTrip for 5
check PathInfoPublishedAtMostOnce for 5
check TripPublicationUsesSourcePathInfo for 5
check PathInfoObstaclesAreConfirmed for 5
check PathInfoHasSegments for 5
check ReviewedPathInfoHasAcquiredData for 5
check PublishedBikePathHasFlag for 5
check TripOwnerMatchesPathInfoOwner for 5
check BikePathContributorMatchesPathInfoOwner for 5

