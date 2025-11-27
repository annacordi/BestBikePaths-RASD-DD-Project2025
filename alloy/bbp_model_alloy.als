

// ============================================
// PRIMITIVE TYPES (defined first)
// ============================================

abstract sig Bool {}
one sig True, False extends Bool {}

// ============================================
// SIGNATURES
// ============================================

// User types
abstract sig User {}

sig UnregisteredUser extends User {}

sig RegisteredUser extends User {
    var isLoggedIn: one Bool
}

// Trip represents personal cycling activity for statistics tracking
sig Trip {
    owner: one RegisteredUser,
    var state: one TripState,
    distance: one Int,
    duration: one Int,
    avgSpeed: one Int,
    var detectedObstacles: set Obstacle,
    var confirmedObstacles: set Obstacle,
    var weatherInfo: lone WeatherData,
    var published: one Bool,
gpsData: set GPSPoint
} {
    distance > 0
    duration > 0
    avgSpeed > 0
    // Confirmed obstacles must be a subset of detected obstacles
    confirmedObstacles in detectedObstacles
}

// PathInfo represents bike path information publishable to the community
sig PathInfo {
    var status: one PathStatus,
    var score: one Int,
    contributor: one RegisteredUser,
    var isPublished: one Bool,
    sourceTrip: lone Trip,
 obstacles: set Obstacle
} {
    score >= 0
    score <= 10
    // If there's a source trip, obstacles must match confirmed obstacles
    some sourceTrip => obstacles = sourceTrip.confirmedObstacles
}

// GPS and location data
sig GPSPoint {
    latitude: one Int,
    longitude: one Int,
    timestamp: one Int
} {
    latitude >= -90 and latitude <= 90
    longitude >= -180 and longitude <= 180
    timestamp >= 0
}


// Obstacle detection
sig Obstacle {
    location: one GPSPoint,
    var obstacleType: one ObstacleType,
    detectedBy: one DetectionMethod
}

abstract sig ObstacleType {}
one sig Pothole, SpeedBump, RoadDamage, Other extends ObstacleType {}

abstract sig DetectionMethod {}
one sig SensorDetection, ManualReport extends DetectionMethod {}

// Weather enrichment
sig WeatherData {
    temperature: one Int,
    windSpeed: one Int,
    precipitation: one Bool
}

// States
abstract sig TripState {}
one sig Recording, Completed, UnderReview extends TripState {}

abstract sig PathStatus {}
one sig Optimal, Medium, Sufficient, RequiresMaintenance extends PathStatus {}

// ============================================
// FACTS - System Invariants
// ============================================

// User constraints
fact UserConstraints {
    // Only registered users can log in
    all u: UnregisteredUser | u.isLoggedIn = False
}

// Trip constraints
fact TripConstraints {
    // Each trip belongs to exactly one registered user
    all t: Trip | one t.owner
    
    // A trip can only be published once
    all t: Trip | t.published = True => 
        (one p: PathInfo | p.sourceTrip = t)
    
    // Published trips must be in Completed state
    all t: Trip | t.published = True => t.state = Completed
    
    // Trips under review cannot have weather info yet
    all t: Trip | t.state = UnderReview => no t.weatherInfo
    
    // Only completed trips can have weather info
    all t: Trip | some t.weatherInfo => t.state = Completed
    
    // Each trip has at least one GPS point
    all t: Trip | some t.gpsData
}

// PathInfo constraints
fact PathInfoConstraints {
    // Published PathInfo must have a positive score
    all p: PathInfo | p.isPublished = True => p.score > 0
    
    // PathInfo from automatic/manual recording has a source trip
    all p: PathInfo | some p.sourceTrip => 
        p.contributor = p.sourceTrip.owner
}

// Obstacle constraints
fact ObstacleConstraints {
    // Each obstacle is associated with at most one trip
    all o: Obstacle | lone t: Trip | o in t.detectedObstacles
    
    // Sensor-detected obstacles can only exist in trips
    all o: Obstacle | o.detectedBy = SensorDetection =>
        some t: Trip | o in t.detectedObstacles
}

// GPS constraints
fact GPSConstraints {
    // GPS points are unique to trips
    all g: GPSPoint | lone t: Trip | g in t.gpsData
}

// ============================================
// PREDICATES - System Behaviors
// ============================================

// User login
pred login[u: RegisteredUser] {
    // Pre: user is not logged in
    u.isLoggedIn = False
    // Post: user is logged in
    u.isLoggedIn' = True
}

// Start manual trip recording
pred startTripRecording[u: RegisteredUser, t: Trip] {
    // Pre: user is logged in
    u.isLoggedIn = True
    // Post: trip is created and in Recording state
    t.owner = u
    t.state = Recording
    no t.detectedObstacles
    no t.confirmedObstacles
    t.published = False
}

// Stop trip recording
pred stopTripRecording[t: Trip] {
    // Pre: trip is in Recording state
    t.state = Recording
    // Post: trip moves to Completed or UnderReview based on obstacles
    some t.detectedObstacles => t.state' = UnderReview
    else t.state' = Completed
}

// Review and confirm obstacles
pred reviewObstacles[t: Trip] {
    // Pre: trip is under review
    t.state = UnderReview
    // Post: user confirms subset of detected obstacles
    t.confirmedObstacles' in t.detectedObstacles
    t.state' = Completed
}

// Publish trip as PathInfo
pred publishTripAsPath[t: Trip, p: PathInfo] {
    // Pre: trip is completed and not yet published
    t.state = Completed
    t.published = False
    // Post: PathInfo is created from trip data
    p.sourceTrip = t
    p.contributor = t.owner
    p.isPublished' = True
    t.published' = True
}

// Manual path insertion
pred insertPathManually[u: RegisteredUser, p: PathInfo] {
    // Pre: user is logged in
    u.isLoggedIn = True
    // Post: PathInfo is created without source trip
    no p.sourceTrip
    p.contributor = u
}

// Automatic cycling detection
pred autoDetectCycling[u: RegisteredUser, t: Trip] {
    // Pre: user is logged in
    u.isLoggedIn = True
    // Post: trip is automatically created
    t.owner = u
    t.state = Recording
    some t.detectedObstacles
    all o: t.detectedObstacles | o.detectedBy = SensorDetection
}

// ============================================
// ASSERTIONS - Properties to Verify
// ============================================

// No trip can be published without being completed first
assert NoPublishBeforeCompletion {
    all t: Trip | t.published = True => t.state = Completed
}

// Published PathInfo must have a contributor
assert PublishedPathHasContributor {
    all p: PathInfo | p.isPublished = True => one p.contributor
}

// Confirmed obstacles are always a subset of detected ones
assert ConfirmedObstaclesAreDetected {
    all t: Trip | t.confirmedObstacles in t.detectedObstacles
}

// Each published trip corresponds to exactly one PathInfo
assert OneToOnePublishedTripPath {
    all t: Trip | t.published = True => 
        one p: PathInfo | p.sourceTrip = t
}

// Only registered users can own trips
assert OnlyRegisteredUsersOwnTrips {
    all t: Trip | t.owner in RegisteredUser
}

// Weather info only for completed trips
assert WeatherOnlyForCompleted {
    all t: Trip | some t.weatherInfo => t.state = Completed
}

// ============================================
// PREDICATES FOR VISUALIZATION
// ============================================

// Show a complete workflow from trip recording to publication
pred showCompleteTripToPathWorkflow {
    some t: Trip, p: PathInfo | {
        t.state = Completed
        t.published = True
        p.sourceTrip = t
        p.isPublished = True
        some t.detectedObstacles
        some t.confirmedObstacles
        some t.weatherInfo
    }
}

// Show manual path insertion scenario
pred showManualPathInsertion {
    some p: PathInfo | {
        no p.sourceTrip
        p.isPublished = True
    }
}

// Show trip under review with obstacles
pred showTripUnderReview {
    some t: Trip | {
        t.state = UnderReview
        some t.detectedObstacles
        t.confirmedObstacles != t.detectedObstacles
        t.published = False
    }
}

// Show automatic detection scenario
pred showAutomaticDetection {
    some t: Trip | {
        some t.detectedObstacles
        all o: t.detectedObstacles | o.detectedBy = SensorDetection
        t.state in UnderReview + Completed
    }
}

// Show multiple users with different trip states
pred showMultipleUsersScenario {
    #RegisteredUser >= 2
    #UnregisteredUser >= 1
    some disj t1, t2: Trip | {
        t1.owner != t2.owner
        t1.state != t2.state
    }
    some p: PathInfo | p.isPublished = True
}

// ============================================
// CHECKS
// ============================================

check NoPublishBeforeCompletion for 5
check PublishedPathHasContributor for 5
check ConfirmedObstaclesAreDetected for 5
check OneToOnePublishedTripPath for 5
check OnlyRegisteredUsersOwnTrips for 5
check WeatherOnlyForCompleted for 5

// ============================================
// RUNS
// ============================================

run showCompleteTripToPathWorkflow for 5 but exactly 1 Trip, exactly 1 PathInfo
run showManualPathInsertion for 5 but exactly 1 PathInfo
run showTripUnderReview for 5 but exactly 1 Trip
run showAutomaticDetection for 5 but exactly 1 Trip
run showMultipleUsersScenario for 6

