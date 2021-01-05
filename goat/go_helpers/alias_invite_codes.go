package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"flag"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

type joinWaitlistRequest struct {
	Email             string `json:"email"`
	ResellApparel     bool   `json:"resell_apparel"`
	ResellAccessories bool   `json:"resell_accessories"`
	ResellSneakers    bool   `json:"resell_sneakers"`
}

func main() {
	fileName := flag.String("file", "", "")
	skipHeader := flag.Bool("skip-header", false, "")
	dryRun := flag.Bool("dry-run", false, "")

	flag.Parse()

	file, err := os.Open(*fileName)
	if err != nil {
		log.Fatal(err)
	}

	reader := csv.NewReader(file)

	if *skipHeader {
		_, err = reader.Read()
		if err != nil {
			log.Fatal(err)
		}
	}

	var emails []string
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}

		emails = append(emails, record[1])
	}

	client := http.DefaultClient
	counter := 0

	for _, email := range emails {
		switch {
		case *dryRun:
			log.Printf("%s", email)
		default:
			body, _ := json.Marshal(map[string]string{
				"email": email,
			})

			req, err := http.NewRequest("POST", "https://sell-api.goat.com/api/v1/unstable/users/join-waitlist", bytes.NewBuffer(body))
			req.Header.Set("User-Agent", "")

			if err != nil {
				log.Printf("could not generate code for %s: %s", email, err.Error())
				continue
			}

			resp, err := client.Do(req)
			if err != nil {
				log.Printf("could not generate code for %s: %s", email, err.Error())
				continue
			}

			defer resp.Body.Close()

			if resp.StatusCode != http.StatusOK {
				log.Printf("could not generate code for %s: %s %s", email, resp.Status, resp.Header.Get("x-goatpub-err-msg"))
				continue
			}

			counter++

			time.Sleep(10 * time.Millisecond)
		}
	}

	log.Printf("Successfully created %d access codes", counter)
}
