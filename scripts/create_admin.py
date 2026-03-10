import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

import bcrypt
from database import postgresDatabase

import bcrypt
from database import postgresDatabase

db = postgresDatabase()

usuario = "admin"
senha = "admin123"

senha_hash = bcrypt.hashpw(
    senha.encode(),
    bcrypt.gensalt()
).decode()

sql = """
INSERT INTO usuarios (usuario, senha, privilegio)
VALUES (%s, %s, %s)
"""

db.writeRaw(sql, (usuario, senha_hash, 2))

print("Usuário admin criado.")