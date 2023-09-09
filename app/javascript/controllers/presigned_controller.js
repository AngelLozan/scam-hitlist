import { Controller } from "@hotwired/stimulus"
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";


export default class extends Controller {
    static targets = ["form", "fileInput", "fileUrl", "link"]

    connect() {
        console.log("Controller connected");
        // console.log(this.fileInputTarget);
        console.log(this.formTarget);
        console.log(this.fileUrlTarget);
    }

    async fetchPresigned() {
        try {
            const file = await this.fileInputTarget.files[0];
            const fileName = file.name;
            const res = await fetch(`/presigned?name=${fileName}`);
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
      } catch(e) {
        console.log(e);
      }
    }

    async handleSubmit(event) {
        event.preventDefault();
        try {
            const path = this.formTarget.action
            const file = this.fileInputTarget.value
            const upload_file_url = this.fileUrlTarget.getAttribute("data-url");

            // Get object key to create download presigned url
            const parts = upload_file_url.split("?");
            const objectKey = parts[0].split("/").pop();
            console.log("Object Key:", objectKey);
            const download = await this.download(objectKey);

            this.fileUrlTarget.value = download
            const formData = await new FormData(this.formTarget);


            // Upload file to S3 Bucket
            console.log("Calling PUT using presigned URL with client");
            await this.put(upload_file_url, file);
            console.log("\nDone. Check your S3 console.");

            // Post form data and create IOC with download url attached so evidence can be accessed.
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

    // async downloadFile (download_url, file_name, e){
    //     e.preventDefault();
    //     try {
    //       const link = this.linkTarget
    //       link.= presignedUrl;
    //       link.download = fileName;
    //       link.target = "_blank";
    //       link.click();
    //     } catch(e) {
    //         console.log(e);
    //     }
    // }



}