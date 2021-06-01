package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"
)

func main() {

	// simulate a startup time
	log.Println("Starting up")
	time.Sleep(25 * time.Second)
	log.Println("Started")

	log.Println("Welcome, user! Curl me (locally with Port 8080/hello) with your name as path :-D")
	http.HandleFunc("/status", StatusServer)
	http.HandleFunc("/sleep", SleepServer)
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

	// Graceful shutdown time is 20 seconds
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		// handle err
	}
	// Wait for ListenAndServe goroutine to close.
    os.Exit(0)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	time.Sleep(2 * time.Second)
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}

func SleepServer(w http.ResponseWriter, r *http.Request) {
	time.Sleep(5 * time.Second)
	fmt.Fprintf(w, "Sleeping done... was good!", r.URL.Path[1:])
}

func StatusServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "up")
}
