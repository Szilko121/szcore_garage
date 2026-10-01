<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&height=190&color=0:05080D,45:0066FF,100:00D4FF&text=SzCore+Garage&fontSize=42&fontColor=FFFFFF&animation=fadeIn&fontAlignY=38&desc=SzCore+Framework+%E2%80%A2+Vehicles&descAlignY=60&descSize=16" width="100%" alt="SzCore Garage" />

<img src="https://readme-typing-svg.demolab.com?font=Orbitron&weight=700&size=21&duration=2500&pause=850&color=00D4FF&center=true&vCenter=true&width=720&height=52&lines=Vehicles;Modular+%E2%80%A2+Server-Authoritative+%E2%80%A2+Developer+First" alt="SzCore Garage animated headline" />

<p><b>Persistent public, job, gang and shared garage system with impound, multiple access points and vehicle-state validation.</b></p>

<p>
  <img src="https://img.shields.io/badge/SzCore-v1.4.0--rc1-8B5CF6?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Type-Vehicles-00D4FF?style=for-the-badge" alt="Type">
  <img src="https://img.shields.io/badge/FiveM-Resource-F40552?style=for-the-badge&logo=fivem&logoColor=white" alt="FiveM">
  <img src="https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
</p>

<p>
<a href="https://github.com/Szilko121/szcore_garage/stargazers"><img src="https://img.shields.io/github/stars/Szilko121/szcore_garage?style=flat-square&logo=github&color=00D4FF" alt="Stars"></a>
<a href="https://github.com/Szilko121/szcore_garage/issues"><img src="https://img.shields.io/github/issues/Szilko121/szcore_garage?style=flat-square&logo=github&color=EF4444" alt="Issues"></a>
<img src="https://img.shields.io/github/last-commit/Szilko121/szcore_garage?style=flat-square&logo=github&color=22C55E" alt="Last commit">
</p>

<p><a href="https://github.com/Szilko121/SzCore-Framework"><b>Framework</b></a> • <a href="https://github.com/Szilko121/SzCore-Framework/tree/main/docs"><b>Docs</b></a> • <a href="https://github.com/Szilko121/SzCore-Recipe"><b>Recipe</b></a> • <a href="https://github.com/Szilko121/szcore_garage/issues"><b>Issues</b></a></p>
</div>

---

## 🚀 Overview

Persistent public, job, gang and shared garage system with impound, multiple access points and vehicle-state validation.

> Garage pickup/store requests validate access, distance, ownership and persistent vehicle state on the server.

## ✨ Highlights

| | Capability |
|---:|---|
| ⚡ | **Public, job, gang and shared garages** |
| 🧩 | **Multiple access and spawn points** |
| 🛡️ | **Persistent owned vehicle integration** |
| 💾 | **Spawn occupancy checks** |
| 🎯 | **Impound fees and reasons** |
| 🔌 | **Runtime garage registration** |

## 📦 Installation

**Dependencies:** `oxmysql`, `szcore`, `szcore_vehicles`, `szcore_vehiclekeys`, `szcore_ui`

```bash
git clone https://github.com/Szilko121/szcore_garage.git "resources/[szcore]/szcore_garage"
```

```cfg
ensure szcore_garage
```

For a complete installation use **[SzCore-Recipe](https://github.com/Szilko121/SzCore-Recipe)**.

## 🔌 API Highlights

`RegisterGarage` · `UnregisterGarage` · `ImpoundVehicle` · `MoveVehicle` · `SetImpoundFee` · `GetGarage` · `OpenGarage`

## 🛡️ Engineering Principles

- Persistent and security-sensitive mutations are validated server-side.
- Feature boundaries stay modular and explicit.
- Client UI/input is not treated as authority.
- Permanent frame loops are used only when FiveM natives require them.
- Performance is measured, not advertised with fixed fake resmon numbers.

## 🧩 Part of SzCore

<div align="center">

[![Framework](https://img.shields.io/badge/SzCore-Framework-00D4FF?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Framework)
[![Recipe](https://img.shields.io/badge/txAdmin-Recipe-2563EB?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Recipe)

<br><br><sub>Built by <b>SzCode</b> for the FiveM community.</sub>
<img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:00D4FF,55:0066FF,100:05080D" width="100%" alt="SzCore footer" />
</div>
