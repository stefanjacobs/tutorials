package main

import (
	"fmt"
	"net/http"
)

func main() {
	fmt.Println("Welcome, user! Curl me (locally with Port 8080) with your name as path :-D")
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
}
