Best Bike Paths — R&DD Project (A.Y. 2025–2026)
Team Members:
Anna Cordioli
Tasnem El Koush
(Reference Professor: Prof. Elisabetta Di Nitto)# Best Bike Paths (BBP) — Requirements Engineering & Design Project

---

## 📌 Project Overview & System Concept

**Best Bike Paths (BBP)** is a theoretical system concept defined for a hypothetical biker association to support urban cycling communities in crowdsourcing, scoring, and routing across optimal bike paths.

The analytical study covers the complete conceptual specification of:
* **Trip Tracking & Performance Telemetry:** Use cases and data workflows for recording bike trips and integrating external weather services.
* **Crowdsourced Path Assessment:** Specification of manual path status reporting alongside an automated mobile sensor acquisition concept (using GPS, accelerometer, and gyroscope data).
* **Algorithmic Path Scoring & Data Merging:** Conceptual formulation of multi-criteria routing scores and rules for resolving conflicting user reports based on freshness and consensus.

---

## 📄 Project Deliverables

The repository contains the sources and generated PDFs for the two official course assignments:

### 1. Requirement Analysis and Specification Document (RASD)
* Drafted following the **IEEE Std 830-1998** standard structure.
* Definition of world phenomena, domain assumptions, user personas, and operational scenarios.
* Complete functional and non-functional requirements specification.
* Structural and behavioral modeling using **UML Use Case Diagrams**, **Activity Diagrams**, and **Statecharts**.
* **Formal Modeling in Alloy:** Rigorous specification of core domain constraints and consistency checks via assertion validation in the Alloy Analyzer.

### 2. Design Document (DD)
* High-level architectural decomposition of the proposed system (Component and Deployment Views).
* Runtime behavior modeled via **UML Sequence Diagrams** mapping component interactions.
* Architectural styles and design patterns selection (e.g., Client-Server, MVC, REST APIs).
* **Requirements Traceability Matrix (RTM):** Explicit cross-reference mapping every RASD requirement to its corresponding design element.
* Proposed integration, test, and rollout plan.

---

## 📂 Repository Structure

```text
.
├── RASD/                   # sources, diagrams, and Alloy models for the RASD
├── DD/                     # sources and architectural diagrams for the DD
├── deliverables/           # Compiled final PDF documents
│   ├── RASDv1.pdf          # Final Requirement Analysis and Specification Document
│   └── DDv1.pdf            # Final Design Document
└── README.md

