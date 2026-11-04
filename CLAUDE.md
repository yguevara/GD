# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

ArchiGenio (formerly SerPerf / "SGD"): a Delphi VCL desktop application for document/archive management (series documentales, expedientes, transferencias, préstamos, depósitos, etc.). UI text, identifiers and comments are in Spanish. There is no linter; the only automated tests are the DUnitX console tests in `Pruebas/` (pure-logic units only, see below).

## Projects and build

- **`ArchiGenioPro.dpr` / `.dproj` is the only project** (main form `TMAIN` in `UMAINFORM.pas`). The old `SerPerf.dpr` predecessor, its exclusive units and the side projects (`UConfig/`, `VARIABLES VIRTUALES…`, `v2Claude/`) were removed on 2026-10-30; a pre-removal copy of the sources is in `bakup/` and the history is in git. `Pruebas/` holds the DUnitX test project (`scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`).
- Build from the command line (Win32, Debug is the default config; output goes to `Win32\Debug\`):
  ```
  call "C:\Program Files (x86)\Embarcadero\Studio\<ver>\bin\rsvars.bat"
  msbuild ArchiGenioPro.dproj /t:Build /p:Config=Debug /p:Platform=Win32
  ```
  The project is Delphi 10.3 (Studio `20.0`; `scripts/compilar.ps1` hardcodes that `rsvars.bat`). Studio 22.0 is also installed but is not what the scripts use. The delphi-dev `delphi-build` skill and the `mcp__delphi__compile_project` tool also cover this.
- **Tests**: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`, then run `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (exit code != 0 on failure; writes `resultados_pruebas.xml`). New test units must be added to `Pruebas/PruebasArchiGenio.dpr`; they can only cover units free of VCL/`UDM` (it is a console app).
- Heavy third-party dependencies must be installed in the IDE to compile: DevExpress (dx*/cx* `RS26`), FastReport (`frx*26`), TMS, JVCL/JCL, Indy, Vcl.Styles (`Metropolis UI Blue` is set in the `.dpr`).
- Every unit is listed in the `.dpr` uses clause (`UFoo in 'UFoo.pas' {frmFoo}`); **new forms/units must be added there** (the IDE does it automatically, hand edits must too). Units in `Clasificadores/` are no longer in git's tree; the active `UCL*.pas` classifier units live in the repo root.
- `__history/`, `__recovery/`, `*.dcu`, `*.~pas` and `Win32/` are IDE/build artifacts; ignore them. Note that `Win32/Debug/*.dcu` and `ArchiGenioPro.identcache` are tracked in git, so every build dirties `git status`; don't stage them.

## Architecture

- **Startup (`ArchiGenioPro.dpr`)**: sets locale (decimal `.`, thousands `,`, date `dd/mm/yyyy`), shows `TfrmSplash`, then looks for `config.ini` next to the exe. If missing (or its edition flag mismatches `VERSION`), `Configurasys(True)` (in `USysConfig.pas`) runs the first-run configuration dialog, which writes `config.ini`. Then creates `UDM` (data module) and `MAIN`. `VERSION` is `'PROFESIONAL'` or `'BÁSICA'` and gates features.
- **`config.ini` format** (line-based, read positionally in `UCapaDatos.pas`): line 0 = DB type (`S` = SQL Server, otherwise MS Access), line 1 = server name (SQL Server) or `.mdb` path (Access), line 2 = database name (SQL Server only).
- **Data layer (`UCapaDatos.pas`, ~5.5k lines, data module `UDM`)**: single global `TFDConnection` (`UDM.Conn`) via FireDAC, with driver `MSSQL` or `MSAcc` chosen at runtime from `config.ini`. The `.dfm` holds a large number of datasets/queries bound to `Conn`; forms reference `UDM.*` directly. The module also contains FTP (Indy) handling, reserved-word lists for both SQL dialects (`SQLServerReservadas`, `AccessReservadas`), and `UpDateDB`, which runs schema migrations on connect. All SQL must work on both Access and SQL Server. `DBTableModifier.pas` (`TDBTableModifier`) is the helper for altering tables/keys across both engines. `.sql` scripts for SQL Server are in `SCRIPTS/`.
- **Main shell (`UMAINFORM.pas`, ~10k lines)**: the `TMAIN` form with menus and the docking/tree UI; it launches nearly every other form. Large cross-cutting globals (`vers`, `programver`, `VersionProgram`, `buildprogram`, `CAPP`, paths like `PathSys`) are declared in the data module's interface.
- **Security**: `USecurityClasss.pas` (`TSecurityClass`) and `md5.pas`; login in `UAutentica`, user admin in `UUserGest`/`UNewUser`/`UChangePass`/`UUserProperties`. Audit logs are viewed through `UAdminLog`.
- **Feature forms by prefix**: `UCL*` = classifier/catalog CRUD forms (cargo, depósitos, tipo de documento, FTP server, etc.); `UManagement*`/`UMangement*` = management forms (nodes, series, index, transfers, PDF files); `UGestEstruct`/`UNode*`/`UNewNode*` = archive structure tree; `UVeditor`/`UREditor`/`UVisorTif` = document/TIFF/rich-text viewers and editors; `UTransferencias`, `UPrestamos`, `UDepuracion` = archive workflow processes; `UExportImport*` and `UExcelExport` = import/export. Reports are FastReport (`.fr3` under `ReportesYoyo/` and `MAISEL REPORT/Report`).
- **Testable "pure" layer (newer code)**: `UAlcance` (roles `TRolNodo` + action rules over the node tree, no DB), `UAlcanceDatos` (loads a user's scope and builds a parametrized SQL filter valid on both engines; single point of scope security for the tree and document search), `UEsquemaAlcance` (idempotent schema DDL; documentary copy in `SCRIPTS/alcance_tablas.sql`), `UTopografia` (physical-location validation for a subserie/node), `UAsignacionDatos`. These deliberately avoid VCL and `TUDM` (RTL + FireDAC at most) so `Pruebas/` can compile them. Keep new business rules there rather than in forms.
- Design specs and plans for the redesign (alcance/roles, EGD assignment, topografía) are in `docs/superpowers/specs/` and `docs/superpowers/plans/`; read the relevant one before changing those areas.
- `uiapp.pas` enforces a single running instance (mutex + window message to activate the existing one).

## Conventions and gotchas

- **Encoding**: source files are ANSI/Windows-1252 (accents like `Versión`, `BÁSICA`). Preserve the file's existing encoding and BOM when editing; the delphi-dev `delphi-encoding` skill applies. Don't rewrite whole files through tools that normalize to UTF-8. Files use CRLF. The newer pure-logic units (`UAlcance`, `UAsignacionDatos`, …) are written in plain ASCII (no accents in comments/strings), which sidesteps the issue; follow that for new code. `CLAUDE.md` itself is UTF-8 and currently untracked in git.
- `.dfm` files are edited both by hand and by the IDE; keep property order and `object`/`end` structure intact. Editing a `.dfm` form means the matching `.pas` published field declarations must stay in sync.
- The working tree has a large number of staged/unstaged deletions (old `Clasificadores/` units and `__history` files, `BD/`); treat `git status` noise in those paths as pre-existing, and don't restore or commit it unasked.
- **Asignación de responsables (SQL Server):** `UAsignacionDatos.pas` (reglas + escritura transaccional, sin VCL) y `UAsignacionNodos.pas` (pantalla por código, sin .dfm; se abre desde Administración de usuarios, botón creado en `UUserGest.FormShow` solo con `TBD = 'S'`). `tb_nodo_egd` admite varios EGD por nodo (clave `IdEstructura,id,user_id`); el EGD ve los descendientes y actúa solo en su nodo.
