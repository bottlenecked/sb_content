# Sportsbook Content (SBContent)
An application to serve as an exploration of what a stateful proxy infront of a 3rd party provider could look like, enabling uniformity of data and change detection.

This is the companion repo to my Build 'n Tell show. New content broadcasted live every Thursday on [Twitch](https://www.twitch.tv/bottlenecked). Previous episodes uploaded on [Youtube](https://www.youtube.com/playlist?list=PLZzHTzu3i9C4iO83yhilPMirCKWeq2g7j)

_warning: opinionated docs and code ahead. And the videos linked to above I guess._

## The problem

Sportsbook operators (i.e. companies operating the actual gambling websites accessible from the end users) oftentimes get their content (matches and odds) from a 3rd party provider. In Stoiximan's case that would be Geneity (now Playtech BGT). The following are some of the problems we've encountered:

- Switching providers can be painful if during the integration phase no time is taken to provide an appropriate abstraction and domain modeling
- Many of the older 3rd party solutions out there expose pull-only APIs. Building stateless apps is a good strategy when time to market is of the essense but as this is the kind of decision that heavily informs the design it is very difficult to then add push capabilities on top
- Stateless apps though infinitely horizontally scalable, usually depend on some kind of central storage mechanism. In Geneity's case the choice of Oracle DB has often proved to be a choke-point for performance; enter _caching_. Caching (through various layers like on the client side, Varnish, Memcached, Redis, SQLite) is the most sensible thing to do to prevent traffic from ever reaching the database but that leads to problems like response inconsistencies: responses can differ depending on the moment and the webserver a request is routed to, based on cache expiration timings- for live matches where something happens every second this means bad user experience (for example 'score-flashing', a situation where the score of a football for example match might oscillate between previous and current/actual score until all servers finally update their cache)
- Getting the exact content a client needs usually involves multiple requests to the backend which tends to both complicate development and introduce response delays

## The solution

The idea is to build a proxy application standing between the 3rd party's APIs and our services so that we can:

- Properly model the domain and make it as provider-agnostic as possible; easier said than done but it can be a great source of pain when migrating to another 3rd party if not done at all
- Provide consistent responses to clients
- Push updates like 'GoalScored' and 'MarketOddsChanged' that will both make customer experience better and allow other services to respond in real-time instead of batching every 5' or so

## Goals
- Provide insight to new engineers on how to break apart large projects and tackle them piecemeal
- Explore the design of such a solution. In particular, I wanted to assess the viability but not provide an e2e implementation. For instance I explore modeling live data for different sports but only implement this for one or two sports- as long as the idea is validated and there's an obvious path to extending a particular feature I move on.
- Obtain a 300ft view of how difficult that would be for a team to implement and support.
- Have fun!

## Application structure

This application is split into folders each with a different concern. I am not a fan of umbrella applications because in my experience they tend to lead to bad designs because of the way configuration is so prominently exposed. But that's just me- if it works for you then use them.

### model
This folder contains the sportsbook domain models. Events, Markets, Selections and live data all reside here

### geneity
This is the provider integration specific code. The end goal is to be able to just replace it in it's entirety should you need to change 3rd party providers

### state
This folder contains the entirety of the available content in memory. That is not as crazy as it sounds because content is limited: at any one time there will only be several tens of thousands of available events globally; as time progresses events will end and new ones will be scheduled or started

### diff_engine
Code that compares two events (previous and next state) and outputs the changes. Changes are published to clients of this application

### sb_graphql
Contains GraphQL related objects, queries, mutations and subscriptions. This is in a separate folder than the api because in theory GraphQL is transport-agnostic; one could use it with transports other than HTTP

### sb_api
The application that exposes the APIs for making GraphQL requests to the state. Also home to integration tests

### root-level scripts
I'm developing on windows [like 4 other guys do](https://elixirforum.com/t/elixir-1-10-3-is-now-available-on-chocolatey-nuget/31307) and I created some powershell scripts for my convenience. You don't need to hold this against me.

## Terminology

There is a hierarchical model describing sportsbook content:

Sport -> Zone -> League -> Event -> Market -> Selection

This doesn't look very flexible on first look but business tends to think in those terms. They also need to apply settings on a per sport / zone / league basis (an example would be: for tier-1 leagues like 'Champion's League' we can offer odds with a smaller operator-margin because we can be more certain of the quality of the data) and this modelling can make it much easier to build what they need.

### Sport
Soccer, Basketball, Ice Hockey and Politics are all modeled as sports. Events within a signle sport share the same rules more or less.

### Zone
Large (usually geographical) areas like 'Europe', 'Latin America' etc.

### League
'Premier League', 'NBA' and 'Eurovision' are all examples of Leagues.

### Event

In sportsbook business lingo an _'event'_ is a match like 'Manchester v Barcelona' or 'US Presidential Elections 2020' - anything really on a calendar that a customer could conceivably bet on. This naming is a bit unfortunate however because it clashes with a term commonly used to describe the notifications services may send to each other; a.k.a 'events'. To differentiate between these two kinds of events the first type of events is often referred to as 'sportsbook events' while the second kind as 'domain events'. But because humans, you'll just need to be aware of this and try to determine the meaning based on context more often than not.

### Market

A grouping of possible related outcomes. 'Match Result' and 'Total points Over / Under' are examples of markets used in a sportsbook

### Selection

One out of several possible outcomes for a markets. For the Match Result market those would be Home Win / Draw / Away win. For the Total Points O/U market it could be 'Over 132.5' and 'Under 132.5'

### Price (odds)

Each selection has an associated price that goes with it, which essentially prescribes how much a bettor can expect to make by betting an amount on a particular selection.

Prices can be represented in any mumber of formats like 'fractional' (UK odds), 'decimal' (European odds), 'American' and others. Odds are calculated based on actual probability of something occuring minus the house margin (ie sportsbook website fee)


