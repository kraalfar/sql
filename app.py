# encoding: UTF-8
import argparse

from datetime import date
import time
## Веб сервер
import cherrypy

# Драйвер PostgreSQL
import psycopg2 as pg_driver



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

## Удобный класс скрывающий от нас работу с БД
class Planet(object):
    def __init__(self, id):
        self.id = id

    def name(self):
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT name FROM Planet WHERE id = %s", (self.id,))
            row = cur.fetchone()
            if row is not None:
                return row[0]
            else:
                return None

    def flight_count(self):
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT id FROM Flight WHERE planet_id = %s", (self.id,))
            flight_ids = cur.fetchall()
            return len(flight_ids)

    def first_flight(self):
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT date FROM Flight WHERE planet_id = %s", (self.id,))
            flight_dates = sorted(cur.fetchall())
            if len(flight_dates) == 0:
                return "---"
            else:
                return flight_dates[0][0].isoformat()

    def last_flight(self):
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT date FROM Flight WHERE planet_id = %s", (self.id,))
            flight_dates = sorted(cur.fetchall())
            if len(flight_dates) == 0:
                return "---"
            else:
                return flight_dates[-1][0].isoformat()


    def to_string(self):
        return '{0}: {1} полётов. Первый {2}. Последний {3}'.format(self.name(), self.flight_count(), self.first_flight(), self.last_flight())

@cherrypy.expose
class App(object):

    @cherrypy.expose
    def hello(self):
    	return "Hello DB"

    ## Это приложение отображает сводную информацию о полётах на каждую планету
    # Что может пойти не так?
    @cherrypy.expose
    def planets(self, planet_id = None):
        out = ""
        start_ts = time.time()
        cherrypy.response.headers['Content-Type'] = 'text/plain; charset=utf-8'
        planets = []
        with get_conn() as db:
            cur = db.cursor()
            cur.execute("SELECT id FROM Planet P")
            planet_ids = cur.fetchall()
            for pid in planet_ids:
                planets.append(Planet(pid[0]))

            out = "\n".join([p.to_string() for p in planets])

        end_ts = time.time()
        out = out + "\n\nСгенерировано за {} сек".format(end_ts - start_ts)
        return out

if __name__ == '__main__':
    cherrypy.quickstart(App())
