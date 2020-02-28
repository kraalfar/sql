# encoding: UTF-8
import argparse

from datetime import date
import time
# Веб сервер
import cherrypy

# Драйвер PostgreSQL
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


# Удобный класс скрывающий от нас работу с БД
class Planets(object):

    def __init__(self):
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("select P.id, P.name, count(P.id), min(F.date), max(F.date) "
                        "from Planet P left join Flight F on (F.planet_id=P.id) "
                        "group by P.id")
            ids = []
            names = []
            flights = []
            first_date = []
            last_date = []
            for row in cur.fetchall():
                if row is not None:
                    ids.append(row[0])
                    names.append(row[1])
                    if row[2]:
                        flights.append(int(row[2]))
                    else:
                        flights.append(0)

                    if row[3]:
                        first_date.append(row[3])
                    else:
                        first_date.append("---")

                    if row[4]:
                        last_date.append(row[4])
                    else:
                        last_date.append("---")
            self.planets = pd.DataFrame(index=ids, data={"name": names,
                                                         "flights": flights,
                                                         "first": first_date,
                                                         "last": last_date})

    def get_all_planets(self):
        out = ""
        for ind, planet in self.planets.iterrows():
            out += f"{planet[0]:8}: {planet[1]:3} полётов. Первый {planet[2]}. Последний {planet[3]}\n"


        return out

@cherrypy.expose
class App(object):

    @cherrypy.expose
    def hello(self):
        return "Hello DB"

    # Это приложение отображает сводную информацию о полётах на каждую планету
    # Что может пойти не так?
    @cherrypy.expose
    def planets(self, planet_id=None):
        start_ts = time.time()
        cherrypy.response.headers['Content-Type'] = 'text/plain; charset=utf-8'

        planets = Planets()

        end_ts = time.time()
        out = planets.get_all_planets() + "\n\nСгенерировано за {} сек".format(end_ts - start_ts)
        return out


if __name__ == '__main__':
    cherrypy.quickstart(App())
