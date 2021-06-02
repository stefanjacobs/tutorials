# README

That go snippet is a small program to query some urls, if they are available. Main purpose is to ensure Downtime free Deployments.
The snippet is taken from https://github.com/josephburnett/kubecon18 and modified (to some degree, my Go skills suck!).

## Output

    19:51:47.11263: 100 ms requests

    ID  COUNT   ERR     LAST RESPONSE
    0   239     0       OK - I am fine.
    1   239     0       OK - I am fine.
    2   239     0       OK - I am fine.
    3   239     0       OK - I am fine.
    4   239     0       OK - I am fine.
    5   239     0       OK - I am fine.
    6   239     0       OK - I am fine.
    7   239     0       OK - I am fine.
    8   239     0       OK - I am fine.
    9   239     0       OK - I am fine.

## How to start

    go run main.go

## Parameters

    timeout     -> http timeout in seconds (Default: 5)
    clientcount -> number of threads/clients (Default: 10)
    sleep       -> milliseconds to sleep between requests (Default: 100)
    url         -> endpoint to query (Default: http://localhost:30726/health)
    maxchar     -> max number of chars of response to show (Default: 100)

## Example calls

Local NginX App in Kubernetes with Nodeport on 30726:

    go run main.go -url http://localhost:30726/health -timeout 30 -clientcount 10 -sleep 100

Remote spiegel.de:

    go run main.go -url http://www.spiegel.de -timeout 30 -clientcount 1 -sleep 1000

Remote https://www.google.com

    go run main.go -url https://www.google.de -timeout 30 -clientcount 1 -sleep 100

## Makefile abbreviations

Standard Makefile:

    make run

Custom Makefile with e.g. secrets in it (urls, etc.)

    make -f Makefile.secret kto-int
