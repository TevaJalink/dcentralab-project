import json, os, sys
import boto3.session
import sqlalchemy as sa
import ssl
from alembic import command
from alembic.config import Config

def lambda_handler(event, context):
    # lambda handler contains the script logic
    # inserts input vales received from api gateway to db
    id = event['queryStringParameters']['id']
    GivenName = event['queryStringParameters']['GivenName']
    Surname = event['queryStringParameters']['Surname']

    ssl_context = ssl.create_default_context()
    db_url = generate_db_url()
    engine = sa.create_engine(db_url, connect_args={"ssl_context": ssl_context})
    if sa.inspect(engine).has_table("hw") is False:
        run_migrations()
        # print will show in cloudwatch logs
        print("Table was created")

    if sa.inspect(engine).has_table("hw") is True:
        try:
            insert_values(engine, id, GivenName, Surname)
        except Exception as e:
            print(f"Error with the insert definition: {e}")
            sys.exit(1)
    return {
        "statusCode": 200,
        "body": json.dumps("Function completed successfully")
    }


def generate_db_url():
    # function used to generate the db url object, first retrives the aws rds proxy token
    # and then uses sql alchemy to create the url object
    aws_region = os.getenv('region')
    postgres_endpoint = os.getenv('rds_endpoint')
    DB_username = os.getenv('username')
    port = os.getenv('port')
    database = os.getenv('database')

    session = boto3.Session(region_name = aws_region)
    client = session.client('rds')
    password = client.generate_db_auth_token(
        DBHostname = postgres_endpoint, Port = port, DBUsername = DB_username, Region = aws_region
    )

    db_url = sa.engine.URL.create(
        drivername="postgresql+pg8000",
        username=DB_username,
        password=password,
        port=port,
        host=postgres_endpoint,
        database=database
    )
    return db_url

def insert_values(engine, id, GivenName, Surname):
    # inserts values to hw table
    metadata = sa.MetaData()
    hw_table = sa.Table("hw", metadata, autoload_with=engine)
    stmt = hw_table.insert().values(id=id ,GivenName=GivenName, Surname=Surname)
    with engine.connect() as conn:
        result = conn.execute(stmt)
    return result

def run_migrations():
    # uses the alembic library lambda-app to create the table
    # the env.py file contains the generate_db_url function as "get_url"
    # so no values are passed to the alembic.ini
    alembic_cfg = Config("alembic.ini")
    response = command.upgrade(alembic_cfg, "head")
    return response

def drop_all_tables(engine):
    # used for testing
    metadata = sa.MetaData()
    user_table = sa.Table('hw', metadata, autoload_with=engine)
    return user_table.drop(engine)
