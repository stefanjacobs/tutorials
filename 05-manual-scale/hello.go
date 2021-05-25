package main

import (
	"fmt"
	"net/http"
    "os"
	"log"
    "os/signal"
    "time"
	"context"
)

func main() {

	log.Println("Welcome, user! Curl me (locally with Port 8080) with your name as path :-D")
	http.HandleFunc("/", HelloServer)
	server := &http.Server{Addr: ":8080"}

    go func() {
        if err := server.ListenAndServe(); err != nil {
            // handle err
        }
    }()

    // Setting up signal capturing
    stop := make(chan os.Signal, 1)
    signal.Notify(stop, os.Interrupt)

    // Waiting for SIGINT (pkill -2)
    <-stop

    ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
    defer cancel()
    if err := server.Shutdown(ctx); err != nil {
        // handle err
    }

    // Wait for ListenAndServe goroutine to close.
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	time.Sleep(5 * time.Second)
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}
