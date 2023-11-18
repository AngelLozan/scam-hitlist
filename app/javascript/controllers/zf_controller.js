import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="zf"
export default class extends Controller {
    static values = {
        ca: String,
        fox: String,
    };

    static targets = ['zfbtn', 'cabtn', 'whois', 'ptbtn', 'evidence', 'modal', 'close', 'phishing', 'spoofing', 'imp', 'copyright', 'tm', 'other', 'malware', 'rouge']

    connect() {
        console.log('connected zf controller');

        // ZeroFox
        const zfbtnStatus = this.zfbtnTarget.getAttribute('data-status');
        console.log(zfbtnStatus);
        if (zfbtnStatus === 'submitted_zf') {
            this.zfbtnTarget.disabled = true;
        }

        // Phish Tank
        const ptbtnStatus = this.ptbtnTarget.getAttribute('data-status');
        console.log(ptbtnStatus);
        if (ptbtnStatus === 'submitted_pt') {
            this.ptbtnTarget.disabled = true;
        }

        // Chain Abuse
        const cabtnStatus = this.cabtnTarget.getAttribute('data-status');
        console.log(cabtnStatus);
        if (cabtnStatus === 'submitted_ca') {
            this.cabtnTarget.disabled = true;
        }
    }

    get csrfToken() {
        const csrfMetaTag = document.querySelector("meta[name='csrf-token']");
        return csrfMetaTag ? csrfMetaTag.content : "";
    }


    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function(event) {
        if (event.target == modal) {
            this.modalTarget.style.display = "none";
        }
    }

    modal() {
        this.modalTarget.style.display = 'block';
    }

    modalClose() {
        this.modalTarget.style.display = 'none';
    }

    async postZFIOC(e) {
        e.preventDefault();
        const url = e.currentTarget.getAttribute('data-url');
        const id = e.currentTarget.getAttribute('data-id');
        const violation = e.currentTarget.getAttribute('data-custom-id');
        let type;

        if (violation === "spoofing") {
            type = 'email'
        } else {
            type = 'url'
        }

        // @dev Implement file attachement from IOC evidence as condition if email

        // /threat_submit/alerts/{alert_id}/attachments

        // const alertId = 123; // Replace with your actual alert ID
        // const fileInput = document.getElementById('file-input'); // Replace with the ID or reference of your file input element

        // // Assuming you have an input element of type 'file'
        // const file = fileInput.files[0];

        // // Create FormData object and append the file
        // const formData = new FormData();
        // formData.append('file', file);

        // // Make the fetch request
        // fetch(`https://api.example.com/threat_submit/alerts/${alertId}/attachments`, {
        //   method: 'POST',
        //   body: formData,
        // })
        //   .then(response => {
        //     if (!response.ok) {
        //       throw new Error(`Request failed with status ${response.status}`);
        //     }
        //     return response.json();
        //   })
        //   .then(data => {
        //     console.log('Attachment added successfully:', data);
        //   })
        //   .catch(error => {
        //     console.error('Error adding attachment:', error);
        //   });


        try {
            let res = await fetch('https://api.zerofox.com/2.0/threat_submit/', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': `${this.foxValue}` },
                body: JSON.stringify({ "source": `${url}`, "alert_type": `${type}`, "violation": `${violation}`, "entity_id": "1194610", "request_takedown": false, "notes": "For review" })
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
                        headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
                        body: JSON.stringify({ 'zf_status': 1 })
                    })
                    console.log(setStatus);
                    let response = await setStatus.json();
                    console.log(response);
                    if (response.zf_status === 'submitted_zf') {
                        this.zfbtnTarget.innerText = 'Submitted!'
                        this.zfbtnTarget.disabled = true;
                        this.displayFlashMessage('Successfully submitted IOC to ZeroFox ✅', 'success');
                    }
                } catch (error) {
                    console.log(error.message);
                    this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
                }

            }

        } catch (error) {
            console.log(error.message);
            this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
        }
    }

    async postPT(e) {
        e.preventDefault();
        const id = e.currentTarget.getAttribute('data-id');
        const url = e.currentTarget.getAttribute('data-url');
        try {
            window.open(url, "_blank");
            let setStatus = await fetch(`/iocs/${id}`, {
                method: 'PATCH',
                headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
                body: JSON.stringify({ 'pt_status': 1 })
            })
            console.log(setStatus);
            let response = await setStatus.json();
            console.log(response);
            if (response.pt_status === 'submitted_pt') {
                this.ptbtnTarget.innerText = 'Submitted!'
                this.ptbtnTarget.disabled = true;
                this.displayFlashMessage('Opened your email client to send a message 👍', 'success');
            }
        } catch (error) {
            console.log(error.message);
            this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
        }
    }


    async postCAIOC(e) {
        e.preventDefault();
        const id = e.currentTarget.getAttribute('data-id');

        try {

            let res = await fetch(`/ca/${id}`, {
                method: 'GET',
                headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken }
                // body: JSON.stringify(requestBody)
            })
            let data = res.json();
            console.log(data); // data.createdReports[0].id
            if (res.status === 201) {
                this.cabtnTarget.innerText = 'Submitted!'
                this.cabtnTarget.disabled = true;

                try {
                    let setStatus = await fetch(`/iocs/${id}`, {
                        method: 'PATCH',
                        headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
                        body: JSON.stringify({ 'ca_status': 1 })
                    })
                    console.log(setStatus);
                    let response = await setStatus.json();
                    console.log(response);
                    if (response.ca_status === 'submitted_ca') {
                        this.cabtnTarget.innerText = 'Submitted!'
                        this.cabtnTarget.disabled = true;
                        this.displayFlashMessage('Successfully submitted IOC to ChainAbuse ✅', 'success');
                    }
                } catch (error) {
                    console.log(error.message);
                    this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
                }
            }
            console.log(data);
        } catch (error) {
            console.log(error.message);
            this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
        }
    }

    // @dev This allows grabbing a new temp download url for evidene that is over limit for presigned url timeframe (see ioc controller)
    async presignedUrl(e) {
        e.preventDefault();
        const evidenceUrl = this.evidenceTarget.href
        const parts = upload_file_url.split("?");
        const key = parts[0].split("/").pop();
        console.log("Object Key:", key);

        try {
            let res = await fetch(`/download_presigned?key=${key}`, {
                method: 'GET'
            });
            const data = await res.json();
            const download = data.download_url;
            console.log("Download url is: ", data.download_url);
            this.evidenceTarget.href = data.download_url;

            // @dev Need to post new url to iocs controller here to preserve url as part of record
            try {
                let setStatus = await fetch(`/iocs/${id}`, {
                    method: 'PATCH',
                    headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": this.csrfToken },
                    body: JSON.stringify({ 'file_url': download })
                })
                console.log(setStatus);
                let response = await setStatus.json();
                console.log(response);
                if (response.ok) {
                    this.displayFlashMessage('Updated file url for next 7 days ✅', 'success');
                }
            } catch (error) {
                console.log(error.message);
                this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
            }

        } catch (error) {
            console.log(error);
            this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
        }
    }

    async copyLookUp(e) {
        e.preventDefault();
        const url = e.currentTarget.getAttribute('data-url');
        try {
            await navigator.clipboard.writeText(url);
            window.open('https://centralops.net/co/', "_blank")
            this.displayFlashMessage('CentralOps opened in new tab 👀', 'success');
        } catch (error) {
            console.log(error.message);
            this.displayFlashMessage(`Something went wrong : ${error.message}`, 'alert_warning');
        }
    }

    displayFlashMessage(message, type) {
        const flashElement = document.createElement('div');
        flashElement.className = `alert alert-${type} alert-dismissible fade show m-1`;
        flashElement.role = 'alert';
        flashElement.setAttribute('data-controller', 'flash');
        flashElement.textContent = message;

        const button = document.createElement('button');
        button.className = 'btn-close';
        button.setAttribute('data-bs-dismiss', 'alert');

        flashElement.appendChild(button);
        // Append the flash message to the page
        document.body.appendChild(flashElement);


        setTimeout(() => {
            flashElement.remove();
        }, 5000);
    }



}