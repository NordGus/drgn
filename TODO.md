# TODO

## Invitation Padlock
- [x] Design the invitation padlock data model.
- [x] Add invitation padlock creation and management on the settings panel.
  - [ ] Implement settings subpanel.
  - [ ] Implement active invitations per character where the character can manually expire them or visualize orphan invitations.
    - [x] Implement invitation padlock creation.
    - [x] Implement invitation padlock expiration.
    - [x] Implement invitation padlock deletion or revoking.
      - [x] Implement invitation padlock deletion.
      - [ ] Implement invitation padlock revocation.
        - [ ] Implement character expulsion.
  - [x] Implement link creation. Maybe used one inspired by [Once - Campfire](https://github.com/basecamp/once-campfire)
  Server invitation links or explore a more "classical" approach, where each character needs to create a new one for
  each new user.
  - [ ] Implement invitation padlock expiration/deletion/rotation.
  - [ ] Design link sharing protocol.
- [ ] Design the invitation padlock flow for character creation.
  - [ ] Implement security.
  - [ ] Implement form.
- [x] Implement invitation padlock expiration mechanism.
## Master Padlock
- [ ] Master padlock data model.
- [ ] Implement master padlocks roles for securing these dangerous system-wide features.
