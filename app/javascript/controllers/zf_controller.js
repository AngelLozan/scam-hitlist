import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="zf"
export default class extends Controller {
  static values = {
    ca: String,
    fox: String,
  };

  static targets = ['zfbtn', 'cabtn', 'whois', 'ptbtn']

  connect() {
    console.log('connected zf controller');

    const zfbtnStatus = this.zfbtnTarget.getAttribute('data-status');
    console.log(zfbtnStatus);
    if (zfbtnStatus === 'submitted_zf') {
      this.zfbtnTarget.disabled = true;
    }

    const ptbtnStatus = this.ptbtnTarget.getAttribute('data-status');
    console.log(ptbtnStatus);
    if (ptbtnStatus === 'submitted_pt') {
      this.ptbtnTarget.disabled = true;
    }
  }

  get csrfToken() {
    const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
    return csrfMetaTag ? csrfMetaTag.content : "";
  }

  async postPT(e){
    e.preventDefault();
    const id = e.currentTarget.getAttribute('data-id');
    const url = e.currentTarget.getAttribute('data-url');
    try {
      window.open(url, "_blank");
      let setStatus = await fetch(`/iocs/${id}`, {
        method: 'PATCH',
        headers: {  "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
        body: JSON.stringify({ 'pt_status': 1 })
      })
      console.log(setStatus);
      let response = await setStatus.json();
      console.log(response);
      if (response.pt_status === 'submitted_pt') {
        this.ptbtnTarget.innerText = 'Submitted!'
        this.ptbtnTarget.disabled = true;
      }
    } catch (error) {
      console.log(error.message);
    }
  }

  async postZFIOC(e){
    e.preventDefault();
    const url = e.currentTarget.getAttribute('data-url');
    const id = e.currentTarget.getAttribute('data-id');
    try {
      let res = await fetch('https://api.zerofox.com/2.0/threat_submit/', {
        method: 'POST',
        headers: {'Content-Type':'application/json', 'Authorization': `${this.foxValue}`},
        body: JSON.stringify({"source": `${url}`, "alert_type": "url", "violation": "phishing", "entity_id": "1194602", "request_takedown": false, "notes": "test please ignore"})
      })
      let data = await res.json();
      console.log(data);
      if (data.alert_id) {
        this.zfbtnTarget.innerText = 'Submitted!'
        this.zfbtnTarget.disabled = true;
        // Update the status via the controller to reviewed.
        try {
          let setStatus = await fetch(`/iocs/${id}`, {
            method: 'PATCH',
            headers: {  "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
            body: JSON.stringify({ 'zf_status': 1 })
          })
          console.log(setStatus);
          let response = await setStatus.json();
          console.log(response);
          if (response.zf_status === 'submitted_zf') {
            this.zfbtnTarget.innerText = 'Submitted!'
            this.zfbtnTarget.disabled = true;
          }
        } catch (error) {
          console.log(error.message);
        }

      }

    } catch (error) {
      console.log(error.message);
    }
  }

  async postCAIOC(e){
    e.preventDefault();
    const url = e.currentTarget.getAttribute('data-url');
    // Add this above domain in below body if needed: "chain": "BTC",
    const requestBody = [
      {
        "addresses": [
          {
            "domain": `${url}`,
            "address": `${url}`
          }
        ],
        "agreedToBeContactedData": {
          "agreed": true,
          "name": "Scott",
          "email": "scott.lo@exodus.io",
          "country": "US"
        },
        "scamCategory": "PHISHING",
        "description": "Phishing Scam"
      }
    ];
    try {
      let res = await fetch('https://api.zerofox.com/2.0/threat_submit/', {
        method: 'POST',
        headers: {'Content-Type':'application/json', 'accept': 'application/json', 'Authorization': `${this.caValue}`},
        body: JSON.stringify(requestBody)
      })
      let data = await res.json();
      if (data.alert_id) {
        this.cabtnTarget.innerText = 'Submitted!'
        this.cabtnTarget.disabled = true;
      }
      console.log(data);
    } catch (error) {
      console.log(error.message);
    }
  }

  async copyLookUp(e){
    e.preventDefault();
    const url = e.currentTarget.getAttribute('data-url');
    try {
      await navigator.clipboard.writeText(url);
      window.open('https://centralops.net/co/', "_blank")
    } catch (error) {
      console.log(error.message);
    }
  }



}
