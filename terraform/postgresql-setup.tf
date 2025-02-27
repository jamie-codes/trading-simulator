# This terraform config automates the database and table creation 

resource "kubernetes_job" "postgresql_setup" {
  metadata {
    name = "postgresql-setup"
    namespace = "default"
  }

  spec {
    template {
      metadata {
        labels = {
          app = "postgresql-setup"
        }
      }

      spec {
        container {
          name  = "postgresql-setup"
          image = "postgres:13"

          env {
            name  = "POSTGRES_USER"
            value = "user"
          }

          env {
            name  = "POSTGRES_DB"
            value = "trading"
          }

          command = [
            "psql",
            "-U", "user",
            "-d", "trading",
            "-c", "CREATE TABLE IF NOT EXISTS trades (id SERIAL PRIMARY KEY, timestamp TIMESTAMP NOT NULL, action TEXT NOT NULL, symbol TEXT NOT NULL, quantity INT NOT NULL, price DECIMAL NOT NULL);"
          ]
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 4
  }
}