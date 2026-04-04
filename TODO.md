# TODO

## Invitation Padlock
- [x] Design the invitation padlock data model.
- [x] Add invitation padlock creation and management on the settings panel.
  - [x] Implement settings subpanel.
  - [x] Implement active invitations per character where the character can manually expire them or visualize orphan
    invitations.
    - [x] Implement invitation padlock creation.
    - [x] Implement invitation padlock expiration.
    - [x] Implement invitation padlock deletion or revoking.
      - [x] Implement invitation padlock deletion.
      - [x] Implement invitation padlock revocation.
        - [x] Implement character expulsion.
  - [x] Implement link creation. Maybe used one inspired by [Once - Campfire](https://github.com/basecamp/once-campfire)
  Server invitation links or explore a more "classical" approach, where each character needs to create a new one for
  each new user.
  - [x] Implement invitation padlock expiration/deletion/rotation.
  - [x] Design link sharing protocol.
- [x] Design the invitation padlock flow for character creation.
  - [x] Implement security.
  - [x] Implement form.
- [x] Implement invitation padlock expiration mechanism.
- [x] Implement orphan cleanup job.
## Master Padlock
- [ ] Master padlock data model.
- [ ] Implement master padlocks roles for securing these dangerous system-wide features.
