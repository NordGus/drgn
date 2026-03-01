# TODO

## Character Sheet
- [x] Add setting panel.
- [x] Add character sheet to settings panel.
  - [x] Implement dangerous action confirmation.
  - [x] Add character base sheet update.
  - [x] Implement character deletion inspired by [Once - Campfire](https://github.com/basecamp/once-campfire).
    - [x] Implement the soft deletion system of the character.
    - [x] Add a character deletion form on the character sheet.
    - [ ] Add a character that has been marked as deleted.
    - [x] Extend the current code to take this into consideration. So, it prevents deleted users from accessing the system.
      - [ ] Extend test cases to also test this.
- [x] Add password padlock key change on the character sheet.
  - [x] Refactor the current method used to handle forgotten passwords to require password confirmation.

## Invitation Padlock
> [!NOTE]
> Maybe move this to a separate feature PR.
- [ ] Design the invitation padlock data model.
  - [ ] Add invitation padlock creation and management on the settings panel.
  - [ ] Design the invitation padlock flow for user creation.