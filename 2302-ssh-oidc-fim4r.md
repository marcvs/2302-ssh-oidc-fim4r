---
# vim:tw=100:ft=markdown
author: Tangui Coulouarn, Martin van Es, Mads Freek Petersen, Diana Gudu, Mikkel Hald, Marcus Hardt, 

title: Federated SSH
<!--Integration of Infrastructure Capacity in EOSC: policy & technical overview-->
date: Feb 2023
theme: marcus
<!-- parallaxBackgroundImage: images/synergy-bg-slide.png -->
<!-- title-slide-attributes: -->
<!--     data-background-image: images/synergy-bg-head.png -->
<!-- slideNumber: \'c/t\' -->
slideNumber: true
preloadIframes: true
pdfSeparateFragments: false
pdfMaxPagesPerSlide: 1
showNotes: false
mouseWheel: true
<!-- transition: none -->
<!--backgroundTransition: none-->

<!--REMOTE_USER: presentations-->
<!--REMOTE_HOST: cvs.data.kit.edu-->
<!--REMOTE_URL: https://infra.eosc-synergy.eu/~presentations/2106-Synergy-Review-WP2-->
<!--REVEAL_DIR: public_html/reveal.js-->
<!--REVEAL_URL: /~presentations/reveal.js-->

---
## Outline

- Motivation / use case:
- Approaches for ssh-oidc
    - Smart Shell
    - SSH Certificates
    - PAM Module
- Implementations and their peculiarities
    - AWI
    - DEIC
    - SURF
    - KIT
- Demos


# Motivation

## Use Case
- Access services via SSH at organisation "`Org`"
- "`Org`" has no (direct) relationship with the users (there is no trusted path)
- Authorisation: Which users to accept?
- How to trust the server host key? Avoid relying on "Trust On First Use" (TOFU)?
- How to revoke access?

## Motivation

(why is this endeavour done)

- As a user
    - Single Sign-On (SSO)
    - No additional service credentials
    <!-- - No need for SSH key management -->
    <!-- - No prior registration -->

- As a server
    - "Generic" benefits of federated AAI
        - Offload identity management to home organisation
        - Offload authorisation management to federation (VOs)
    <!-- - Bridges the gap from federated  to local identity -->
    <!--     - Provides a mapping of federated identities to local accounts -->
    <!--         - Plugins allow for custom mappings -->
    <!--     - Supports management of the lifecycle of local accounts -->
    <!--         - create, update, suspend -->

## Problems

- @Tangui: You said a "problems" section would be required.
    - Shoot

# Approaches

## Smart Shell

- Replace the actual shell
- Present user with a link at which to authenticate
- Sudo after successful authentication / authorisation
- PROs
    - Straightforward to install
- CONs
    - `scp` won't work
    - User interaction and web (device) login required for each login

## SSH Certificates

- Provision ssh root-certificate on `ssh`-server
- Setup a web page for initial registration
- Provide ssh-certificate to user
- PROs
    - ssh-certificates supported in standard `ssh`
- CONs
    - ...
- Bonus: DEIC's implementation can also hand-out certificates via `ssh`

## PAM Module

- Works on a lower level than "Smart" Shell
- PROs
    - Allows prompting user e.g. for "Access Token", "Device Code"
- CONs
    - "PAM Module" frighten (some) admins

## GSSAPI

- CONs
    - Nobody looked into that yet :-(


# Implementations

## AWI

- Based on smart-shell
- Integration with additional tool "`krest`" to obtain a kerberos ticket (for NFS4 mounts)

## DEIC

- Based on SSH-Certificates
- ......

## SURF

- Based on smart-shell
- .....

## KIT

- Based on PAM module
- Modular extensions included
    - User provisioning / deprovisioning
        - Pluggable backend (local unix, LDAP, REST)
        - Pluggable username creation (smart, pooled, existing, external)
    - Security incident support
    - VO/Entitlement based authorisation
    - Assurance

- PROs
    - I guess it does not make sense to have PROs here, they're all above.
- CONs
    - Works best with additional client-side packages
        - Requirement being removed as we speak

# Demos

## Demos

- Either we link to each solution's demo here, or we add one on the per solution slides.
- For our solution I will try to life-demo.

