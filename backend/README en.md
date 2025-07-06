# Caretime Backend

This folder contains the backend API for the Caretime project (Node.js + Express + MongoDB).

## Prerequisites
- Node.js >= 16
- MongoDB (local or remote)

## Installation

1. Clone the repository and go to the `backend` folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file at the root of the `backend` folder with the following content:
   ```env
   MONGO_URI=mongodb://localhost:27017/clinic
   JWT_SECRET=supersecretkey
   PORT=5000
   ```
   - Adjust `MONGO_URI` to your MongoDB setup.
   - `JWT_SECRET`: secret key for JWT tokens.
   - `PORT`: server listening port (optional, defaults to 5000).

## Start the server

- In production mode:
  ```bash
  npm start
  ```
- In development mode (with auto-reload):
  ```bash
  npm run dev
  ```

The server will be available at `http://localhost:5000` (or the port you set).

## Seeders (test data)

To populate the database with test data (users, availabilities, appointments):

```bash
npm run seed
```

> ⚠️ **Warning**: This command will delete all existing data in the affected collections!

See [seeders/README.md](./seeders/README.md) for more details.

## Folder structure

- `controllers/`: Route logic (users, appointments, admin...)
- `models/`: Mongoose schemas (User, Appointment, Availability)
- `routes/`: Express route definitions
- `middlewares/`: Middlewares (authentication, etc.)
- `seeders/`: Scripts to populate the database
- `server.js`: Main server entry point

## Available scripts

- `npm start`: Start the server
- `npm run dev`: Start the server in development mode (nodemon)
- `npm run seed`: Run the seeders (test data)

## REST API

Main routes are available under `/api/`:
- `/api/users`: Auth, user management
- `/api/appointments`: Appointments (patients, doctors)
- `/api/availability`: Doctor availabilities
- `/api/admin`: Admin functions (stats, global management)

> See the source code for details on endpoints and parameters.