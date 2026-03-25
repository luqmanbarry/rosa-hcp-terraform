# cluster-logging

Installs the logging operator and configures log forwarding with the Logging 6 API model.

## Responsibilities

- installs the operator
- creates collector service account and RBAC
- optionally creates `ClusterLogForwarder`

## Default

- operator installed
- forwarding disabled until a real destination is configured

## Required Inputs When Enabling Forwarding

- destination URL
- secret containing authentication token
