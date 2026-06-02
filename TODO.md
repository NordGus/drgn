# TODO

## Boss Keys
- [x] Master padlock data model.
  - [x] Write the design document.
  - [x] Implement the base data model.
- [x] Implement locksmith feature settings.
  - [x] Make it so it can only manage settings and features authorization.
  - [x] Make access level updates instantly reactive on the affected character.
  - [ ] Implement all the missing test cases.
- [x] Implement a concern to protect the controllers with the `BossKey` authorization.
- [x] Extend current `Character` and `Padlock::Invitation` to handle `BossKey` creation.
  - [x] Include it on the `Character` model
  - [x] Include it on the `Padlock::Invitation` model.
- [x] Implement a system where all ActionCable channels communications are done via a background job.
- [x] Implement Boss Key padlocks roles for securing these dangerous system-wide features.
  - [x] Implement invitations feature boss key model.
    - [x] Implement the model
    - [x] Add authorization to ActionCable channels.
    - [x] Refactor views to use the authorization system.
- [ ] Implement all missing tests.
- [ ] Integrate boss key removal to invitation revocation actions.
