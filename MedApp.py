import argparse
import time
import cherrypy
import psycopg2 as pg_driver
import pandas as pd

parser = argparse.ArgumentParser(description='Hello DB web application')
parser.add_argument('--pg-host', help='PostgreSQL host name', default='localhost')
parser.add_argument('--pg-port', help='PostgreSQL port', default=5432)
parser.add_argument('--pg-user', help='PostgreSQL user', default='postgres')
parser.add_argument('--pg-password', help='PostgreSQL password', default='')
parser.add_argument('--pg-database', help='PostgreSQL database', default='postgres')

args = parser.parse_args()


def get_conn():
    return pg_driver.connect(user=args.pg_user,
                             password=args.pg_password,
                             host=args.pg_host,
                             port=args.pg_port,
                             database=args.pg_database)


class Meds(object):

    def __init__(self, drug_id):
        if drug_id:
            query = "with big as( select M.tradename, P.number,  cost " \
                    "from Medicine M join MedsInPharmas MP on (M.id=MP.medicineid) " \
                    f"join Pharmacy P  on (P.id = MP.pharmacyid) where amount > 0 and M.id={drug_id} ), " \
                    "Pcount as( select count(*) from Pharmacy) " \
                    "select  * from big cross join Pcount order by big.tradeName;"

        else:
            query = "with big as( select M.tradename, P.number, cost " \
                    "from Medicine M join MedsInPharmas MP on (M.id=MP.medicineid) " \
                    f"join Pharmacy P  on (P.id = MP.pharmacyid) where amount > 0), " \
                    "Pcount as( select count(*) from Pharmacy) " \
                    "select  * from big cross join Pcount order by big.tradeName;"

        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute(query)

            self.names = []
            self.pharma_cnt = []
            self.min_cost = []
            self.numbers = []
            for row in cur.fetchall():
                if row is not None:
                    if len(self.names) == 0 or self.names[-1] != row[0]:
                        self.names.append(row[0])
                        self.pharma_cnt.append(0.)
                        self.min_cost.append(-1)
                        self.numbers.append([])

                    self.pharma_cnt[-1] += 1 / row[3]
                    if self.min_cost[-1] == -1 or row[2] < self.min_cost[-1]:
                        self.min_cost[-1] = row[2]
                        self.numbers[-1] = [row[1]]
                    elif row[2] == self.min_cost[-1]:
                        self.numbers[-1].append(row[1])

    def to_string(self):
        out = ""
        for i in range(len(self.names)):
            out += f"{self.names[i]} продается в {100 * self.pharma_cnt[i]:.2f} аптеках " \
                f"с минимальной ценой {self.min_cost[i]} в аптеках:"

            for j in range(len(self.numbers[i]) - 1):
                out += f" {self.numbers[i][j]},"
            if len(self.numbers[i]):
                out += f" {self.numbers[i][-1]}.\n"
            else:
                out += "( \n"
        return out


@cherrypy.expose
class App(object):

    @cherrypy.expose
    def hello(self):
        return "Hello DB"


    @cherrypy.expose
    def drug_id(self, drug_id=None):
        cherrypy.response.headers['Content-Type'] = 'text/plain; charset=utf-8'

        meds = Meds(drug_id)

        out = meds.to_string()
        return out


if __name__ == '__main__':
    cherrypy.quickstart(App())
