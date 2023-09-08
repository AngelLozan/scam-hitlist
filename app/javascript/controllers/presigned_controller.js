import { Controller } from "@hotwired/stimulus"
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";


export default class extends Controller {
    static targets = ["form", "fileInput", "fileUrl"]

    connect() {
        console.log("Controller connected");
        // console.log(this.fileInputTarget);
        console.log(this.formTarget);
        console.log(this.fileUrlTarget);
    }

    async fetchPresigned() {
        try {
            const res = await fetch('/presigned');
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

    async handleSubmit(event) {
        event.preventDefault();
        try {
            const path = this.formTarget.action
            const file = this.fileInputTarget.value
            const upload_file_url = this.fileUrlTarget.getAttribute("data-url");
            this.fileUrlTarget.value = upload_file_url
            const formData = await new FormData(this.formTarget);

            await formData.set('file_url', upload_file_url);

            console.log("Calling PUT using presigned URL with client");
            await this.put(upload_file_url, file);
            console.log("\nDone. Check your S3 console.");

            let res = await fetch(path, {
                method: 'POST',
                body: formData
            });
            let data = await res.json();

            if (data.show_url) {
                window.location.href = data.show_url;
            } else {
                console.log("Data:", data);
            }

        } catch (e) {
            console.log(e);
        }

    }



}