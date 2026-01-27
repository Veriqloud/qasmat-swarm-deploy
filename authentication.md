# Identity Provider Setup (OpenID Connect)

This application relies on an **OpenID Connect (OIDC)**–compliant Identity Provider (IdP) for authentication and authorization. Any standard IdP (such as Keycloak, Auth0, Okta, Azure AD, etc.) can be used, provided it supports OIDC.

The setup requires:

* One **realm / tenant** (or equivalent concept)
* One **client for the API**
* One **client for the web application**
* At least one **user**
* Properly configured **environment variables**

---

## 1. Create a Realm / Tenant

Create a logical authentication domain (often called a *realm*, *tenant*, or *directory*, depending on the provider).

This issuer URL will be used by both the API and the web client to validate tokens.

---

## 2. Create an API Client

Create an OIDC client representing the backend API.

### Required settings

* **Protocol**: OpenID Connect
* **Client ID**: e.g. `api`
* **Client authentication**: Enabled (confidential client)
* **Grant types**:

  * Authorization Code (or equivalent standard flow)
* **Redirect URIs**: Not required for pure API usage

### Token requirements

* The API must accept **access tokens** issued by the IdP
* Tokens must include:

  * The correct **issuer (`iss`)**
  * The API client listed as an **audience (`aud`)**

---

## 3. Create a Web Client

Create a second OIDC client for the web application.

Let `WURL` be the base URL where the web client is served.

### Required settings

* **Protocol**: OpenID Connect
* **Client ID**: e.g. `web`
* **Client type**: Public or confidential (depending on your deployment)
* **Grant types**:

  * Authorization Code (standard flow)

### Redirect and origin configuration

* **Redirect URI**:

  ```
  WURL/callback
  ```
* **Post-logout redirect URI**:

  ```
  WURL
  ```
* **Allowed origins / CORS**:

  ```
  WURL
  ```

---

## 4. Configure API Audience for the Web Client

The web client must be able to obtain access tokens **intended for the API**.

Ensure that:

* The API client ID (`api`) is included in the **audience** of access tokens issued to the web client
* Access tokens include the API audience claim

This is commonly achieved by:

* Adding an **audience / resource / scope mapping**
* Enabling the API client as an allowed audience in access tokens

But some ID providers include it by default.

---

## 5. Add Users

Create one or more users in the realm/tenant.

Each user should have:

* A username (or email)
* Credentials (password or external identity)
* Optional roles or groups, if your authorization model requires them

---

## Compatibility Notes

This setup is compatible with any Identity Provider that:

* Supports OpenID Connect
* Issues JWT access tokens
* Allows configuring audiences and redirect URIs

Keycloak is commonly used for local development and testing, but the same concepts apply to managed IdPs.
