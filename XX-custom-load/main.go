package main

import (
	"flag"
	"fmt"

	// "io"
	"crypto/tls"
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"time"
)

var (
	timeout     = flag.Int("timeout", 5, "http timeout in seconds")
	clientcount = flag.Int("clientcount", 10, "client count")
	sleep       = flag.Int("sleep", 100, "milliseconds to sleep, min is 1")
	maxchar     = flag.Int("maxchar", 300, "max chars to show of response")
	url         = flag.String("url", "http://localhost:30726/health", "endpoint to get")
	contentType = flag.String("contentType", "", "contenttype like 'text/plain' or 'application/x-www-form-urlencoded'")
	contentFile = flag.String("contentFile", "", "file containing post content")

	contentPost string
)

type client struct {
	requestCount int
	errCount     int
	lastResponse string
	err          error
}

func (c *client) start(stopCh <-chan struct{}) {
	tickerCh := time.NewTicker(time.Millisecond * time.Duration(*sleep)).C
	for {
		select {
		case <-tickerCh:
			urlWithParams := fmt.Sprintf("%v", *url)
			timeoutSetting := time.Duration(time.Duration(*timeout) * time.Second)
			tr := &http.Transport{
				TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
				DisableKeepAlives: true,
			}
			client := &http.Client{
				Timeout: timeoutSetting,
				Transport: tr,
			}
			client.CloseIdleConnections()
			var resp *http.Response = nil
			var err error = nil
			if *contentFile != "" {
				resp, err = client.Post(urlWithParams, *contentType, strings.NewReader(contentPost))
			} else {
				resp, err = client.Get(urlWithParams)
			}
			if err != nil || resp == nil {
				c.err = err
				c.errCount++
				if err != nil {
					c.lastResponse = err.Error()
				} else {
					c.lastResponse = "unknown, probably post-request timeout"
				}
				continue
			}
			if resp.StatusCode >= 400 {
				// c.err = resp.StatusCode
				c.errCount++
				// continue
			}
			defer resp.Body.Close()
			if resp.Body != nil {
				body, err := ioutil.ReadAll(resp.Body)
				if err != nil {
					c.err = err
					c.lastResponse = err.Error()
					continue
				}
				c.err = nil
				c.lastResponse = strings.TrimSpace(string(body))
				c.requestCount++
			}
		case <-stopCh:
			return
		}
	}
}

func main() {
	flag.Parse()
	if *clientcount < 1 {
		panic("clientcount must be at least 1")
	}

	if *contentFile != "" {
		file, err := os.Open(*contentFile)
		if err != nil {
			fmt.Println(err)
		}
		contentBytes, err := ioutil.ReadAll(file)
		file.Close()
		contentPost = string(contentBytes)
		// fmt.Println(contentPost)
	}

	stopCh := make(chan struct{})
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		<-c
		close(stopCh)
	}()
	clients := make([]*client, *clientcount)
	for i := 0; i < *clientcount; i++ {
		c := &client{}
		go c.start((<-chan struct{})(stopCh))
		clients[i] = c
	}
	tickerCh := time.NewTicker(time.Second).C
	for {
		select {
		case <-tickerCh:
			t := time.Now()
			fmt.Printf("%v: %v ms requests\n\n", t.Format("15:04:05.00000"), *sleep)
			fmt.Printf("ID\tCOUNT\tERR\tLAST RESPONSE\n")
			for i, client := range clients {
				responseLength := len(client.lastResponse)
				if responseLength > *maxchar {
					responseLength = *maxchar
				}
				fmt.Printf("%v\t%v\t%v\t%v\n", i, client.requestCount, client.errCount, client.lastResponse[0:responseLength])
			}
			fmt.Printf("\n\n")
		case <-stopCh:
			os.Exit(0)
		}
	}
}
