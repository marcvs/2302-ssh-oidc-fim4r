---
# vim:tw=100:ft=markdown
author: Tangui Coulouarn, Martin van Es, Mads Freek Petersen, Diana Gudu, Mikkel Hald, Marcus Hardt, 

title: SSH with OIDC
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

- THIS IS A TEST
- THIS IS A TEST
- THIS IS A TEST

- Problem Description
- Tools for obtaining access tokens
    - oidc-agent
    - mytoken
- Authentication based on access tokens
    - flaat

## Problem Statement

- OIDC (OpenID Connect) is most often used with web-browser
    - Tokens end up at webserver
    - Webserver can access APIs
- Direct access (without involvement of web-browser) not well supported
- Copy-paste scenarios are not feasible: Tokens expire after ~1h.
- Our goal: Support Non-web + rare-user interaction authentication
- Particular use cases:
    1. Authenticated access to remote services
        - from Desktop / Commandline
        - access to storage (webDAV), or remote hosts (SSH)
    1. Long running compute jobs

# [`oidc-agent`](https://indigo-dc.gitbook.io/oidc-agent)

## `oidc-agent`<br/><smaller><https://indigo-dc.gitbook.io/oidc-agent/></smaller>

- Goals:
    - Provide Access Tokens to user
    - Minimal user interaction
- Analogy to `ssh-agent` is intentional:
    - Runs on local workstation of the user
    - Stores "private keys" on local workstation of the user
    - `oidc-gen`: Generate an OIDC configuration
    - `oidc-add`: Load an OIDC configuration
    - `oidc-token`: Obtain OIDC Access Tokens

## Security

- `oidc-agent` uses `Refresh Tokens`
    - Require high level of protection
- Encrypted storage on disk
- Obfuscated storage in RAM

## Using oidc-agent

- **Once in a life time** (~1 Year): Create a configuration:
    <small> (triggers an `auth-code-flow`; `device-code-flow` is also supported)</small>

    ```bash
    oidc-gen eduteams --issuer https://proxy.eduteams.org  --scope max
    ```
<hr/>

- **Once per reboot**: Load encrypted configuration into memory
    <small>(triggers password prompt; GUI or cmdline; May be skipped)</small>

    ```bash
    oidc-add eduteams
    ```
<hr/>

- **Often**: Obtain token:<br/>
    <small>(Auto-adds config, when `oidc-add` was skipped)</small>

    ```bash
    oidc-token eduteams
    oidc-token https://proxy.eduteams.org
    ```

## Use case 1

- "Authenticated access to remote services"

    ```
    URL=https://proxy.eduteams.org; \
        curl $URL/OIDC/userinfo -H "Authorization: Bearer `oidc-token $URL`" | jq          
    ```

<n class="fragment fade-in">
 Solved
 </n>


## Bottomline `oidc-agent` 

- Use case #1 solved:  "Authenticated access to API":
- Supported Platforms:<br/>
<img src="images/debian.png" height="60px" align="middle"/>
<img src="images/ubuntu.png" height="60px" align="middle"/>
<img src="images/centos.png" height="60px" align="middle"/>
<img src="images/rocky.png" height="60px" align="middle"/>
<img src="images/suse.png" height="60px" align="middle"/>
<img src="images/mac.png" height="60px" align="middle"/>
<img src="images/windows.png" height="60px" align="middle"/>

# [`mytoken`](https://mytoken-docs.data.kit.edu)

## `mytoken`<br/><smaller><https://mytoken-docs.data.kit.edu></smaller>

- Goals:
    - Provide Access Tokens to **long-running jobs**
    - **No interaction** with the user
    - **DO NOT** release Refresh Tokens to the infrastructure

- Challenge:
    - Balance Security vs. Convenience

- Approach:
    - Introduce `mytoken server`: Obtains `Refresh Token` via authorisation code flow.
    - Introduce new token type, called "**`mytoken`**"
    - **`Refresh Tokens`** (stay on server) are encrypted with **`mytoken`** (given to client)

## Balance Security vs. Convenience

- **`mytokens`** are `jwt` style tokens, that
    <ul>
    <li class="fragment fade-in" data-fragment-index="1"> contain Capabilities: "What can I do with the mytoken"<n class="fragment fade-in" data-fragment-index="3">
    <li class="fragment fade-in" data-fragment-index="4"> contain Restrictions: "What are the limits to use the mytoken"<n class="fragment fade-in" data-fragment-index="6">
    <li class="fragment fade-in" data-fragment-index="7"> support inheritance: "Use mytoken to derive another **more limited** mytoken"
        </ul>
<li class="fragment fade-in" data-fragment-index="9">
  See it life and in colour:
    - <https://mytoken.data.kit.edu>
    - <https://mytoken-docs.data.kit.edu>
</ul>

<div class="fragment fade-in-then-out" data-fragment-index="2"
     style="position: fixed;
            top:-6%; left: 66%;
            width: 45%;
            <!--background-color: rgba(255, 255, 2, 0.9);-->
            ">
<img src="images/capabilities.png" width="100%"/><br/>
</div>
<div class="fragment fade-in-then-out" data-fragment-index="5"
     style="position: fixed;
            top:-6%; left: 78%;
            width: 32.5%;
            <!--background-color: rgba(255, 255, 2, 0.9);-->
            ">
<img src="images/restrictions.png" width="100%"/><br/>
</div>

## Demo

- The following examples are also shown in the live demo
- Obtain a `mytoken`:
    1. Via commandline:

    ```bash
    mytoken MT --oidc --issuer https://proxy.eduteams.org
    ```

    2. Via web: from the [mytoken server](https://mytoken.data.kit.edu)
- We store the `mytoken` obtained in `$MYTOKEN`

## Examples

- Inspect the `mytoken`:

    ```bash
    $ echo $MYTOKEN | decodejwt.sh
    ```
    ```json
    {
        "alg": "ES512",
        "typ": "MT+JWT"
    }
    {
    "ver": "0.6",
    "token_type": "mytoken",
    "iss": "https://mytoken.data.kit.edu/",
    "sub": "N071dtAYzya4W32aHGXaze07ywqKMZ/2B2MSVY4uBuw=",
    "seq_no": 1,
    "aud": "https://mytoken.data.kit.edu/",
    "oidc_sub": "7ca006d6b7e61023cec493a74e57849ae9145815@eduteams.org",
    "oidc_iss": "https://proxy.eduteams.org",
    "exp": 1674835490,
    "nbf": 1674144337,
    "iat": 1674144337,
    "auth_time": 1674144337,
    "jti": "0502ae85-1dde-44a0-8965-5db2360fe4ed",
        [...]
    }
    ```


## Examples

- Inspect the `mytoken` (continued)

    ```json
    [...]
    "capabilities": [
        "AT",
        "tokeninfo"
    ],
    "restrictions": [
        {
            "exp": 1674230630
        },
        {
            "nbf": 1674749030,
            "exp": 1674835490
        }
    ]
    ```

## Examples

- Get another `mytoken`, using a `$MYTOKEN`:

    ```bash
    $ mytoken MT --restrictions '{
        "nbf": 1674760000,
        "exp": 1674800000,
        "usages_AT": 1,
        "geoip_allow": [
            "DE"
        ]
    }' --MT $MYTOKEN | decodejwt.sh 
    ```
    ```json
    [...]
        "capabilities": [
            "AT",
            "tokeninfo"
        ],
        "restrictions": [
            {
                "exp": 1673969694,                                                                         
                "exp": 1674600000,
                "usages_AT": 1,
                "usages_other": 1
            }
        ]
    }
    ```

## Examples

- Get an Access Token from a `mytoken`:
    <br/><smaller>Find [decodejwt.sh here](https://repo.data.kit.edu/tools/decodejwt.sh).</smaller>

    ```bash
    $ mytoken AT --MT $MYTOKEN | decodejwt.sh
    ```
    ```json
    {
        "alg": "RS256",
        "typ": "JWT",
        "kid": "PUYOirA3Y-d_dGpdj4iJDHw4zHa8IY-bhZdaEj0rjbU"
    }
    {
        "exp": 1673967087,
        "iat": 1673963487,
        "auth_time": 1673958960,
        "jti": "8ff30cdd-cbab-4ee8-bf9d-5e219fd55324",
        "iss": "https://aai.egi.eu/auth/realms/egi",
        "sub": "d7a53cbe3e966c53ac64fde7355956560282158ecac8f3d2c770b474862f4756@egi.eu",
        "typ": "Bearer",
        "azp": "mytoken",
        "session_state": "9336c983-befa-476c-b494-82a49f04d661",
        "scope": "openid eduperson_unique_id eduperson_scoped_affiliation eduperson_entitlement cert_entitlement ssh_public_key profile email orcid",
        "sid": "9336c983-befa-476c-b494-82a49f04d661",
        "authenticating_authority": "https://idp.scc.kit.edu/idp/shibboleth"
    }
    ```

## Bottomline `mytoken`

- `mytokens` can be adjusted to the situation in which they are used
- `mytokens` can be as safe as possible  --  and as unsafe as necessary
- `mytokens` can be revoked
- `mytokens` can mostly be used just as any other OIDC JWT token
- `mytoken` server <https://mytoken.data.kit.edu> will soon be hosted according to the [EugridPMA
    Credential Store](https://www.eugridpma.org/guidelines/trustedstores).
- Supported Platforms:
    
<img src="images/debian.png" height="60px" align="middle"/>
<img src="images/ubuntu.png" height="60px" align="middle"/>
<img src="images/centos.png" height="60px" align="middle"/>
<img src="images/rocky.png" height="60px" align="middle"/>
<img src="images/suse.png" height="60px" align="middle"/>
<img src="images/mac.png" height="60px" align="middle"/>
<img src="images/windows.png" height="60px" align="middle"/>

# Serverside

## flaat<br/><smaller><https://flaat.readthedocs.io>

- Goals:
    - Python
    - Simple to use
    - Flexible to use
    - Just add "AAI" to python REST API
        </ul></ul>
<ul class="fragment fade-in"> - `flaat` supports these web-frameworks
<ul>
    <li> [`flask`](https://palletsprojects.com/p/flask)
    <li> [`fastapi`](https://fastapi.tiangolo.com)
    <li> [`aiohttp`](https://docs.aiohttp.org/)
</ul></ul>

## flaat

- Usage 
    - Define requirement(s) (on user)
    - Use python **`decorator`** mechanism to enable access control

- Entitlements: `flaat` natively supports
    - [AARC-G027](https://aarc-community.org/guidelines/aarc-g027)
    - [AARC-G069](https://aarc-community.org/guidelines/aarc-g069)
- Can be used to support other profiles
    - e.g. WLCG or SciTokens

- Supported Platform:
    - python3.6+ <br/><img src="images/python.png" height="60px" align="middle"/>


## Example

<small>Require an authenticated user</small>

```python
# Endpoint which requires of an authenticated user
@app.get("/authenticated")
@flaat.is_authenticated()
def authenticated(request: Request,
    return "This worked: there was a valid login".
```

## Example

<small>Require an authenticated user to carry two entitlements</small>
```python
# The user needs belong to a certain virtual organisation
vo_requirement = get_vo_requirement(
    [
        "urn:geant:eduteams.org:service:eduteams:group:LAGO-AAI",
        "urn:geant:eduteams.org:service:eduteams:group:eduTEAMS",
    ],
    "eduperson_entitlement",
    match=2,
)

@app.get("/authorized_vo")
@flaat.requires(vo_requirement)
def authorized_vo(request: Request):
    return "This worked: user has the required entitlement(s)"
```

## Bottomline `flaat`

- Simple support for enforcing AAI in python REST interfaces is available

# Summary

## Summary

- Using OIDC in REST APIs is
    - straightforward
    - on client and server
- The presented tools are a subset of available tools
- All tools are developed at Karlsruhe Institute of Technology (KIT) <img style="vertical-align:middle" src="images/kit-logo.png" height="40px" />
- For questions:
    - Contact: hardt@kit.edu
 
 
