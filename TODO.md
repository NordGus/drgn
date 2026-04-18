# TODO

## Boss Keys
- [ ] Master padlock data model.
  - [x] Write the design document.
  - [ ] Implement the base data model.
- [ ] Implement locksmith feature settings.
  - [ ] Make it so it can only manage settings and features authorization.
- [ ] Extend current `Character` and `Padlock::Invitation` to handle `MasterKey` creation.
- [ ] Implement a system where all ActionCable channels communications are done via a background job.
- [ ] Implement master padlocks roles for securing these dangerous system-wide features.
  - [ ] Implement invitations feature master key model.
    - [ ] Add authorization to ActionCable channels.
