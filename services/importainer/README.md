# Saasform

[![License](https://img.shields.io/github/license/saasform/saasform.svg)](https://github.com/saasform/saasform/blob/master/LICENSE)
[![Discord Chat](https://img.shields.io/badge/chat-Discord-green.svg)](https://discord.gg/cbWW8akyW9)

Add signup & payments to your SaaS in minutes, with Saasform!

[![Saasform demo](https://raw.githubusercontent.com/saasform/saasform/main/docs/images/saasform-demo-video.png)](https://youtu.be/YCboaYBL7g4)

Building a SaaS requires building a website, authentication, payments... and maintaining and updating them... all distractions from your core features. Saasform pre-packages all the things you and your team need to launch faster and grow more effectively. Everything is a module, so you can pick & choose what you need.

Saasform is built with security and usability in mind. It's a standalone service including its own datastore, i.e. it's not a boilerplate, so you can build your SaaS with the tech stack you'd like, even serverless. All you need to do is to integrate Saasform authentication in your backend or functions. This architecture is great to launch quickly, keep you focused on your core features, and maintain a good separation as your infrastructure and team scale.

## Get Started

Launch Saasform:

```bash
git clone https://github.com/saasform/saasform
cd saasform
docker-compose pull && docker-compose up
```

Open your browser at [http://192.168.50.242:7000](http://192.168.50.242:7000).

## Anonymous Telemetry

Saasform uses [Humbug](https://github.com/bugout-dev/humbug) to collect anonymous usage stats and error reporting. If you want to **opt out** edit [docker-compose.yml](https://github.com/saasform/saasform/blob/main/docker-compose.yml#L32) and remove the `HUMBUG_TOKEN` line.

## Next Steps

1. [Customize the website](https://docs.saasform.dev/start/customize-website) (Set name, pricing, content, analytics)
1. Try out the user flows (Sign up, verify email, add payment)
1. [Integrate user authentication](https://docs.saasform.dev/start/integrate-user-authentication) (Technical)
1. Develop Saasform (Technical)
1. Get ready for production (Technical)
1. Migrate to Saasform Cloud

## Features

- Webpages
  - [x] Homepage (modular: use Saasform or redirect to yours)
  - [x] Login / Signup / Password reset
  - [x] Account settings
    - [x] General
    - [x] Security
    - [x] Billing
    - [x] Team
  - [x] Landing pages (privacy policy, download whitepaper...)
  - [x] Multi-theme support
  - [ ] Modals
- User authentication
  - [x] Email + password
  - [x] Security emails (verification, password reset...)
  - [x] Team support (invite new user)
  - [x] Google oauth / SSO
  - [x] Microsoft Azure AD (incl. Office 365)
  - [x] Okta
  - [x] [Miracl](https://miracl.com)
  - [ ] Session management
  - [ ] Enterprise SSO / SAML
- Subscription payments
  - [x] Stripe integration
  - [x] [Kill Bill](https://killbill.io)
  - [ ] Invoicing
- Growth tools
  - [x] Google Analytics (new GAv4!)
  - [x] Facebook Pixel
  - [x] Google Tag Manager
  - [x] Chatbot (Hubspot, Intercom, [Chaskiq](https://chaskiq.io))
  - [ ] More analytics (Matomo, Plausible, GoatCounter, ...)
  - [ ] CRM (Hubspot, ...)

## Screenshots

Coming soon!

## Architecture

![Saasform architecture](https://raw.githubusercontent.com/saasform/saasform/main/docs/images/saasform-architecture.png)

## Contribute

We love any type of contribution, bug fixes, new integrations and better docs. Get started by running [Saasform in dev mode](https://docs.saasform.dev/contrib/dev).

## Saasform Cloud

Saasform Cloud is our hosted solution and we're onboarding beta customers. Join our [Discord channel](https://discord.gg/cbWW8akyW9) or drop us a line at [hello@saasform.dev](mailto:hello@saasform.dev).

[![Code quality via LGTM](https://img.shields.io/lgtm/grade/javascript/g/saasform/saasform.svg)](https://lgtm.com/projects/g/saasform/saasform/context:javascript)
