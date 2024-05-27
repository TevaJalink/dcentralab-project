"""empty message

Revision ID: 91317dca53eb
Revises: 
Create Date: 2024-05-20 21:15:19.550055

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '91317dca53eb'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'hw',
        sa.Column('id', sa.Integer, primary_key=True, nullable=False),
        sa.Column('GivenName', sa.String(15), nullable=False),
        sa.Column('Surname', sa.String(20), nullable=False)
    )


def downgrade() -> None:
    return op.drop_table('hw')
