# TODO

## Boss Keys
- [ ] Master padlock data model.
  - [x] Write the design document.
  - [x] Implement the base data model.
- [ ] Implement locksmith feature settings.
  - [ ] Make it so it can only manage settings and features authorization.
- [ ] Implement a concern to protect the controllers with the `BossKey` authorization.
- [ ] Extend current `Character` and `Padlock::Invitation` to handle `BossKey` creation.
- [ ] Implement a system where all ActionCable channels communications are done via a background job.
- [ ] Implement Boss Key padlocks roles for securing these dangerous system-wide features.
  - [ ] Implement invitations feature boss key model.
    - [x] Implement the model
    - [x] Add authorization to ActionCable channels.
    - [x] Refactor views to use the authorization system.
