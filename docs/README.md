# DGRN Technical Documentation

## Abstract

DRGN (read as Dragon) is tough out to be not only a personal finances control platform, but also as an experiment on how
to structure a modern Ruby-on-Rails full-stack application with the following requirements:

- Self-hosted with minimal dependencies.
  - Mostly the entire Ruby-on-Rails Framework, minimal to no additional Ruby dependencies.
  - Implemented using the new Solid backend for Cache, ActionCable and ActionJob.
  - Minimal to zero system dependencies, aside form the ones required by Ruby-on-Rails.
  - Minimal to zero JavaScript dependencies, bundlers or preprocessors, aside from the ones required and provided by
  Ruby-on-Rails.
  - No CSS frameworks, preprocessors or dependencies.
  - Modern Web standard JavaScript and CSS supported by Chromium-based browers.
  - Easy to deploy using Kamal and Containers.
- Flexible Authentication model.
  - Implementing first a password-based authentication model
  - Easily extendable to include OAuth from different providers and Passkeys.
- Simple Authorization model.
  - Modeled over the data sandboxing inspired by column-defined multitenancy for ease of use.
  - Simple role-based level of access owner/admin, editor and viewer.
  - And a global roles to manage the global configurations of the platform.
- Data Sandboxing modeled over a column-based implementation of multi-tenancy. Using a master model to sandbox the
platform data.
- A weighted directed graph data structure based model to define and store user's transactions ledgers (the `Ledger Graph`).
  - Build using to simple concept Account nodes and Transaction edges Ledgers.
  - Simple and reliable to build interesting features over it.
  - Transaction edges should be able to model the concept that it can be issued one day and be executed in the future.
  - Account nodes should be able to have child Account nodes. For the `Ledger Graph` parent Account nodes and child
  Account nodes on the graph, but child Account nodes store a reference to its parent. Enabling a `Accounts Tree` to
  build future powerful features and quality-of-life features
- A file system for users to have a centralized storage for all their financial documentation.
  - Design over a file tree data structure so the user can work with a familiar UX like, Google Drive, OneDrive,
  iOS/iPadOS Files, macOS Finder and Windows File Explorer.
  - Flexible enough to attach to any record in the data model.
  - Store multiple versions of files.
  - Be easily searchable.
- Enable Budgeting.
  - Allow the user to define their own budgeting cycle.
  - Store their fixed costs/transactions.
  - Give the user a clear view of their financial health.
- Gamify personal finances.
  - Steal Xbox's Achievements system or PlayStation's Trophies.
  - Allow the user to set custom Goals and Targets and platform should react to them.

## Technical considerations
  - DRGN is not a horizontal scalable application.
  - There will only by 2 process running at all times: Web Server and Solid Queue.
  - Sessions are store on the database.
  - There will be no more than 10 concurrent users at maximum.
    - So sqlite with Rails' defaults are sufficient.
  - DRGN is more like a Network accessible platform that behaves like a desktop single computer application. 
  - No Build JavaScript is needed to simplify deployment and stability.
    - So Propshaft is sufficient.
  - Background Jobs are heavily used, so concurrent programming is a given. Some of their uses:
    - For heavy database calculations.
    - Communications between subsystems, like event handlers.
    - Communications between data sandboxes.
    - Session expiration.
  - There will be heavy use of WebSockets (ActionCable) for realtime interactivity/reactivity.
    - Notifications.
    - UI refresh.
