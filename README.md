
#### Overview

This application allows users to manage assets and groups through a RESTful API. It includes authentication, asset management, and group management functionalities.

#### Dependencies

- **Elixir**: Elixir is the programming language used for developing this application. It runs on the Erlang VM.
- **Phoenix Framework**: Phoenix is a web framework for Elixir, used here to build the RESTful API server. It provides features like routing, controllers, and views.
- **Ecto**: Ecto is a database wrapper and query generator for Elixir. It handles database interactions, migrations, and schema definitions.
- **SQLite3**: SQLite3 is used as the database for this application. It's a lightweight, serverless database engine that stores data in a single file.

#### Prerequisites

- Elixir: Make sure you have Elixir installed. You can check the version using `elixir -v`.
- Phoenix Framework: Install Phoenix by following the [official installation guide](https://hexdocs.pm/phoenix/installation.html).
- SQLite3: Ensure you have SQLite3 installed. You can install it via your operating system's package manager or download it from the [SQLite website](https://sqlite.org/download.html).

#### Setting Up the Application

1. Clone the Repository:

   ```bash
   git clone <repository_url>
   cd <repository_directory>
  
2. Install Dependencies:

   ```bash
   mix deps.get

3. Set Up the Database:

   ```bash
   mix ecto.create
   mix ecto.migrate

4. Run the Server:

   ```bash
   mix phx.server

By default, the server will run on http://localhost:4000.

#### API Endpoints

Here is a list of available API endpoints and how to use them with curl.

1. **Authenticate**

   - **Endpoint**: `/api/login`
   - **Method**: POST
   - **Description**: Authenticates a user and returns a JWT token.
  
  JWT for API Security

  JSON Web Tokens (JWT) are used for secure authentication and authorization in this application. Upon successful authentication using the /api/login endpoint, the server generates a JWT token containing encoded information about the user. This token is then sent back to the client and must be included in the Authorization header for subsequent requests requiring authentication.

  Example JWT Token
  ```plaintext
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
  ```

  After obtaining the JWT token, include it in the Authorization header for authorized API requests.

  The server validates the JWT token with each request, ensuring that the user is authenticated and authorized to access the requested resources. If the token is invalid or expired, the server responds with an appropriate error message.

   ```bash
   curl --request POST \
     --url http://localhost:4000/api/login \
     --header 'Content-Type: application/json' \
     --data '{
       "username": "admin",
       "password": "secret"
     }'
  ```

2. **Create an Asset**

   - **Endpoint**: `/api/assets`
   - **Method**: POST
   - **Description**: Creates a new asset.

  ```bash
  curl --request POST \
  --url http://localhost:4000/api/assets \
  --header 'Authorization: Bearer <JWT_Token>' \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "MyAsset14",
    "type": "document",
    "tags": [
      {
        "key": "category",
        "value": "documents"
      },
      {
        "key": "format",
        "value": "pdf"
      }
    ],
    "cloud_account": {
      "id": "def456",
      "name": "AWS"
    },
    "owner_id": "user123",
    "region": "us-west-2"
  }'
  ```

3. **Get an Asset**

   - **Endpoint**: `/api/assets/:id`
   - **Method**: GET
   - **Description**: Retrieves an asset by ID.
  
  ```bash 
  curl --request GET \
    --url http://localhost:4000/api/assets/<asset_id>
  ```

4. **Search for Asset**

   - **Endpoint**: `/api/assets/search`
   - **Method**: POST
   - **Description**: Searches for assets based on criteria.
  

  Applying Multiple Criteria with “AND”

  If your criteria are:
  ```json
  {
  "criteria": [
    {
      "field": "name",
      "operator": "like",
      "value": "MyAsset"
    },
    {
      "field": "owner_id",
      "operator": "==",
      "value": "user123"
    },
    {
      "field": "tags",
      "operator": "==",
      "key": "category",
      "value": "documents"
    }
  ]
}
```

These will be combined using “AND”.

If you want to handle OR conditions explicitly, structure your payload like this:
  ```json
{
  "criteria": [
    {
      "condition": "OR",
      "criteria": [
        {
          "field": "name",
          "operator": "like",
          "value": "MyAsset"
        },
        {
          "field": "owner_id",
          "operator": "==",
          "value": "user123"
        }
      ]
    },
    {
      "field": "tags",
      "operator": "==",
      "key": "category",
      "value": "documents"
    }
  ]
}
```

In this case, the first two criteria will be combined with “OR”, and the result will be combined with the third criterion using “AND”.

Here’s how to construct a curl request for combined AND and OR conditions:
```bash
curl -X POST http://localhost:4000/api/assets/search \
-H "Content-Type: application/json" \
-d '{
  "criteria": [
    {
      "condition": "OR",
      "criteria": [
        {
          "field": "name",
          "operator": "like",
          "value": "MyAsset"
        },
        {
          "field": "owner_id",
          "operator": "==",
          "value": "user123"
        }
      ]
    },
    {
      "field": "tags",
      "operator": "==",
      "key": "category",
      "value": "documents"
    }
  ]
}'
```

5. **List All Assets**

   - **Endpoint**: `/api/assets`
   - **Method**: GET
   - **Description**: Lists all assets.
  
  ```bash 
  curl --request GET \
    --url http://localhost:4000/api/assets

6. **Update an Asset**

   - **Endpoint**: `/api/assets/:id`
   - **Method**: PATCH
   - **Description**: Updates an asset’s fields.
  
  ```bash 
  curl --request PATCH \
  --url http://localhost:4000/api/assets/<asset_id> \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "Updated Asset Name"
  }'
  ```

7. **Delete an Asset**

   - **Endpoint**: `/api/assets/:id`
   - **Method**: DELETE
   - **Description**: Deletes an asset by ID.

   ```bash
   curl --request DELETE \
     --url http://localhost:4000/api/assets/<asset_id>
   ```
8. **Create a Group**

   - **Endpoint**: `/api/groups`
   - **Method**: POST
   - **Description**: Creates a new group.

   ```bash
   curl --request POST \
    --url http://localhost:4000/api/groups \
    --header 'Content-Type: application/json' \
    --data '{
      "name": "group1",
      "rules": [{"field": "type", "operator": "==", "value": "ec2-instance"}]
    }'
    ```
9. **Get Assets by Group**

   - **Endpoint**: `/api/groups/:id/assets`
   - **Method**: GET
   - **Description**: Retrieves assets belonging to a group.

   ```bash
   curl --request GET \
    --url http://localhost:4000/api/groups/<group_id>/assets
   ```
10. **Update a Group**

   - **Endpoint**: `/api/groups/:id`
   - **Method**: PATCH
   - **Description**: Updates a group’s fields.

   ```bash
  curl --request PATCH \
  --url http://localhost:4000/api/groups/<group_id> \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "Updated Group Name",
    "rules": [{"field": "type", "operator": "==", "value": "updated-value"}]
  }'
  ```

#### Monitoring and Debugging

##### Phoenix Live Dashboard

Phoenix Live Dashboard is a powerful tool for monitoring and debugging Phoenix applications in real-time. It provides a visual interface to gain insights into various aspects of the application's performance and state.

#### Features:

- **Metrics**: Real-time metrics including request rates, latencies, memory usage, and more.
- **Interactive Debugging**: Ability to inspect current connections, running processes, and endpoints.
- **Database Insights**: View database queries, transaction times, and connection pool usage.

#### Usage:

1. **Accessing the Dashboard**: Once your application is running in development mode, navigate to `http://localhost:4000/dashboard` in your web browser to access the dashboard.

2. **Exploring Metrics**: Use the dashboard to monitor various metrics and gain insights into your application's behavior.

3. **Debugging and Inspection**: Utilize the dashboard to debug issues, inspect current connections, and evaluate the live state of your application.

4. **Customization**: Customize the dashboard to display metrics and information relevant to your application's specific needs.

For more detailed information on configuring and utilizing Phoenix Live Dashboard, refer to the official [Phoenix Live Dashboard Documentation](https://hexdocs.pm/phoenix_live_dashboard/).
