import json, os, ssl
import boto3.session
import sqlalchemy as sa

def lambda_handler(event, context):
    try:
        # Lambda handler contains the script logic
        ssl_context = ssl.create_default_context()
        db_url = generate_db_url()
        engine = sa.create_engine(db_url, connect_args={"ssl_context": ssl_context})
        metadata = sa.MetaData()
        hw = sa.Table('hw', metadata, autoload_with=engine)
        query = sa.select(hw)
        with engine.connect() as connection:
            result = connection.execute(query).fetchall()
        # Convert the result to a list of dictionaries
        result_dicts = [dict(row._mapping) for row in result]
        return {
            "statusCode": 200,
            "body": json.dumps(result_dicts)
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
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