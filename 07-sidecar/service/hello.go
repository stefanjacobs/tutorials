package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"time"
	"syscall"
)

func getenvStr(key string, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func getenvInt(key string, fallback string) int {
	s := getenvStr(key, fallback)
	v, err := strconv.Atoi(s)
	if err != nil {
		return 0
	}
	return v
}

func getenvBool(key string, fallback string) bool {
	s := getenvStr(key, fallback)
	v, err := strconv.ParseBool(s)
	if err != nil {
		return false
	}
	return v
}

func main() {

	// simulate a startup time
	log.Println("Starting up")
	time.Sleep(time.Duration(getenvInt("STARTUP_SEC", "25")) * time.Second)
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
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)

	// Waiting for SIGINT (pkill -2)
	<-stop

	// Graceful shutdown time is 20 seconds
	ctx, cancel := context.WithTimeout(context.Background(),
		time.Duration(getenvInt("GRACEFUL_SHUTDOWN_SEC", "20"))*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		// handle err
	}
	// Wait for ListenAndServe goroutine to close.
	os.Exit(0)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	time.Sleep(time.Duration(getenvInt("REQUEST_SEC", "5")) * time.Second)
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}

func SleepServer(w http.ResponseWriter, r *http.Request) {
	time.Sleep(time.Duration(getenvInt("SLEEP_SEC", "5")) * time.Second)
	fmt.Fprintf(w, "Sleeping done... was good!")
}

func StatusServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "up")
}
