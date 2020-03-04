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
        if drug_id is not None:
            try:
                drug_id = int(drug_id)
            except ValueError:
                raise ValueError("Expected number as drug_id")

            query = """with T1 as(
                            select M.id, M.tradename,
                                   count(MP) / (select count(*) from pharmacy)::NUMERIC  as cnt,
                                   min(MP.cost) as minCost
                            from Medicine M join MedsInPharmas MP on (M.id = MP.medicineId)
                            where M.id={0}
                            group by M.id
                        ), T2 as(
                               select M.id, M.tradename, MP.cost, MP.pharmacyId
                               from Medicine M join MedsInPharmas MP on (M.id = MP.medicineId)
                               where M.id={0})
                        select T2.tradename, T1.cnt, T1.minCost,  array_agg(T2.pharmacyId)
                               from T1 join T2 on (T1.id = T2.id) 
                               where T2.cost = T1.minCost
                               group by T2.tradename, T1.cnt, T1.minCost;""".format(drug_id)
        else:
            query = """with T1 as(
                            select M.id, M.tradename,
                                   count(MP) / (select count(*) from pharmacy)::NUMERIC  as cnt,
                                   min(MP.cost) as minCost
                            from Medicine M join MedsInPharmas MP on (M.id = MP.medicineId)
                            group by M.id
                        ), T2 as(
                               select M.id, M.tradename, MP.cost, MP.pharmacyId
                               from Medicine M join MedsInPharmas MP on (M.id = MP.medicineId))
                        select T2.tradename, T1.cnt, T1.minCost,  array_agg(T2.pharmacyId)
                               from T1 join T2 on (T1.id = T2.id) 
                              where T2.cost = T1.minCost
                               group by T2.tradename, T1.cnt, T1.minCost
                               order by T2.tradename;"""

        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute(query)

            self.names = []
            self.pharma_cnt = []
            self.min_cost = []
            self.numbers = []
            for row in cur.fetchall():
                self.names.append(row[0])
                self.pharma_cnt.append(row[1])
                self.min_cost.append(row[2])
                self.numbers.append(row[3])

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
