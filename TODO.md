# TODO

## Settings System

- [ ] Design some primitives to implement these concept of user defined System Setting.
  - [ ] Design an interval settings primitive.
    - [ ] Implement Padlock::Invitation expiration interval setting 
    - [ ] Implement Padlock::Password expiration interval setting
    - [ ] Implement Session expiration interval settings
  - [ ] Design an integer settings primitive.
    - [ ] Implement Padlock::Password max history size setting
  - [ ] Design a string settings primitive.
  - [ ] Design a settings group settings primitive.
    - [ ] Implement an SMTP Email Provider settings group.  
  - [ ] Design a selected settings group settings primitive.
- [ ] Implement a control settings panel
  - [ ] Implement BossKey to protect this settings panel
- [ ] Implement ActionMailer interceptor to use the user defined settings to send emails
