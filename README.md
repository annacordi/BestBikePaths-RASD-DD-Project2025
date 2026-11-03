Best Bike Paths — R&DD Project (A.Y. 2025–2026)
Team Members:
Anna Cordioli
Tasnem El Koush
(Reference Professor: Prof. Elisabetta Di Nitto)# Best Bike Paths (BBP) — Requirements Engineering & Design Project

---

## 📌 Project Overview

**Best Bike Paths (BBP)** is an end-to-end software system designed for cycling communities to crowd-source, browse, and optimize bike route inventories across urban areas.

### Key System Capabilities:
* **Trip Tracking & Performance Telemetry:** Automatic and manual recording of cycling sessions with real-time tracking of route segments, average speed, elevation, and integration with meteorological weather services.
* **Crowdsourced Path Quality & Hazard Detection:** Multi-modal road assessment:
  * *Manual Mode:* Users report path conditions and identify road hazards (e.g., potholes, obstacles).
  * *Automated Mode:* Autonomous cycling activity detection via mobile sensor fusion (accelerometer, gyroscope, and GPS telemetry) to infer road surface degradation with mandatory user validation.
* **Intelligent Pathfinding & Freshness-Weighted Scoring:** Multi-criteria path evaluation based on safety, surface quality, directness, and automated consensus algorithms that weigh fresh vs. outdated user reports.

---

## 👥 Authors & Academic Context

* **Anna Cordioli** ([@annacordi](https://github.com/annacordi))
* **Tasnem El Koush** ([@TasnemElKoush](https://github.com/TasnemElKoush))

* **Institution:** Politecnico di Milano
* **Course:** Software Engineering 2 (Prof. Elisabetta Di Nitto)
* **Academic Year:** 2025–2026

---

## 📂 Repository Structure

The project artifacts are structured in compliance with standard IEEE software engineering guidelines:

```text
.
├── RASD/                   # LaTeX source files, UML diagrams, and Alloy models for the RASD
├── DD/                     # LaTeX source files, architectural diagrams, and component specs for the DD
├── deliverables/           # Compiled, publication-ready PDF deliverables
│   ├── RASD_v1.pdf         # Requirement Analysis and Specification Document
│   ├── DD_v1.pdf           # Design Document
│   └── Alloy_Model.als     # Validated formal verification model
└── README.md               # Project documentation and summary
