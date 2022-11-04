### Setup

  Make sure you have docker installed on your system

  To setup run the following command

  `docker build -t backend_eng_task .`

### Run Project

  To run enter following command

  `docker run --rm -it --entrypoint bash backend_eng_task`

  This will open a bash inside docker container

  now we can run our fetch command

  `./fetch https://www.google.com https://autify.com https://stackoverflow.com`

  `./fetch --metadata https://www.google.com`

  then you can verify the metadata output and run ls command to see the `www.google.com.html` and other files getting created.
