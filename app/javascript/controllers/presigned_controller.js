import { Controller } from "@hotwired/stimulus"
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";


export default class extends Controller {
    static targets = ["form", "fileInput", "fileUrl", "link", "alert"]

    connect() {
        console.log("Controller connected");
        // console.log(this.fileInputTarget);
        // console.log(this.formTarget);
        // console.log(this.fileUrlTarget);
    }

    async fetchPresigned() {
        try {
            const file = await this.fileInputTarget.files[0];
            const fileName = file.name;
            const res = await fetch(`/presigned?fileName=${fileName}`);
            const data = await res.json();
            console.log("The url is:", data);
            this.fileUrlTarget.setAttribute("data-url", data.presigned_url);
            // return(data.presigned_url);
        } catch (e) {
            console.log(e);
        }
    }

    put(url, data) {
        return new Promise((resolve, reject) => {
            fetch(url, {
                    method: 'PUT',
                    headers: {
                        'Content-Length': new Blob([data]).size.toString(),
                    },
                    body: data,
                })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error('Request failed with status ' + response.status);
                    }
                    return response.text();
                })
                .then((responseBody) => {
                    resolve(responseBody);
                })
                .catch((error) => {
                    console.log(error);
                    reject(error);
                });
        });
    }

    async download(key) {
        try {
            let res = await fetch(`/download_presigned?key=${key}`, {
                method: 'GET'
            });
            const data = await res.json();
            console.log("Download url is: ", data.download_url);
            return (data.download_url);
        } catch (e) {
            console.log(e);
        }
    }

    async handleSubmit(event) {
        event.preventDefault();
        try {
            const path = this.formTarget.action;
            const fileValue = this.fileInputTarget;
            let formData;

            if (fileValue.files.length > 0) {
                const file = fileValue.files[0];
                const upload_file_url = this.fileUrlTarget.getAttribute("data-url");
                // Get object key to create download presigned url
                const parts = upload_file_url.split("?");
                const objectKey = parts[0].split("/").pop();
                console.log("Object Key:", objectKey);
                const download = await this.download(objectKey);
                this.fileUrlTarget.value = download
                formData = await new FormData(this.formTarget);
                // Upload file to S3 Bucket
                console.log("Calling PUT using presigned URL with client");
                await this.put(upload_file_url, file);
                console.log("\nDone. Check your S3 console.");
            } else {
                console.log("NO FILE");
                formData = await new FormData(this.formTarget);
            }

            // Post form data and create IOC with download url attached so evidence can be accessed.
            let res = await fetch(path, {
                method: 'POST',
                body: formData
            });
            let data = await res.json();

            if (data.show_url) {
                window.location.href = data.show_url;
                this.displayFlashMessage(data.alert_success, 'success');
            } else if (data.errors){
                console.log("Data:", data);
                this.displayFlashMessage(data.errors, 'success');
                this.formTarget.reset();
            } else {
                console.log("Data:", data);
                this.displayFlashMessage(data.alert_warning, 'warning');
            }

        } catch (e) {
            console.log(e);
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
        document.body.appendChild(flashElement);

        setTimeout(() => {
            flashElement.remove();
        }, 5000);
    }



}