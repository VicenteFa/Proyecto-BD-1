import csv
import random
from datetime import date, timedelta
import os

# --- CONFIGURACIÓN DE DATOS REALISTAS ---
PAISES = ["Chile", "Argentina", "Reino Unido", "Alemania", "Japon"]
GEOGRAFIA = {
    "Chile": {"Metropolitana": ["Santiago", "Puente Alto", "Maipú", "La Florida", "Las Condes"], "Valparaíso": ["Viña del Mar", "Valparaíso", "Quilpué", "Villa Alemana", "San Antonio"]},
    "Argentina": {"Buenos Aires": ["La Plata", "Mar del Plata", "Quilmes", "Avellaneda", "Lanús"], "Córdoba": ["Rio Cuarto", "Villa María", "Carlos Paz", "Alta Gracia", "Jesús María"]},
    "Reino Unido": {"Greater London": ["Croydon", "Barnet", "Ealing", "Bromley", "Enfield"], "West Midlands": ["Coventry", "Wolverhampton", "Solihull", "Sutton Coldfield", "Dudley"]},
    "Alemania": {"Baviera": ["Munich", "Nuremberg", "Augsburg", "Regensburg", "Ingolstadt"], "Hamburgo": ["Altona", "Bergedorf", "Eimsbüttel", "Harburg", "Nord"]},
    "Japon": {"Tokyo": ["Shinjuku", "Shibuya", "Minato", "Chiyoda", "Taito"], "Osaka": ["Sakai", "Higashiosaka", "Toyonaka", "Hirakata", "Suita"]}
}
CALLES = {
    "Chile": ["Av. Providencia", "Calle Bandera", "Av. Libertador B. O'Higgins", "Calle Ahumada", "Av. Apoquindo"],
    "Argentina": ["Av. Corrientes", "Calle Florida", "Av. Santa Fe", "Av. de Mayo", "Calle Lavalle"],
    "Reino Unido": ["Oxford Street", "Baker Street", "Abbey Road", "High Street", "Regent Street"],
    "Alemania": ["Unter den Linden", "Kurfürstendamm", "Reeperbahn", "Maximilianstraße", "Königsallee"],
    "Japon": ["Takeshita-dori", "Omotesando", "Dotonbori", "Ginza", "Nakamise-dori"]
}
MARCAS_BASE = ["Gold Leaf", "Royal Blend", "Mountain Mist", "Ocean Breeze", "Urban Classic", "Midnight Silk", "Highland Peak", "Silver Lining", "Amber Haze", "Pure Essence"]

# --- PARÁMETROS DEL PROYECTO ---
FECHA_INICIO = date.today() - timedelta(days=3 * 365) 
DIAS_ENTRE_COMPRAS = 15 

def generar_datos():
    print("Iniciando generación de datos...")
    
    # Función auxiliar para convertir booleano a formato Postgres ('t'/'f')
    def b_to_pg(val):
        return 't' if val else 'f'
    
    # 1. Fabricantes
    fabricantes_list = []
    with open('fabricantes.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for pais in PAISES:
            for i in range(1, 11):
                nombre = f"{pais} Tabacco Co. {i}"
                fabricantes_list.append((nombre, pais))
                writer.writerow([nombre, pais])

    # 2. Cigarrillos
    cigarrillos = []
    with open('cigarrillos.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for fab_nombre, pais in fabricantes_list:
            for m in MARCAS_BASE:
                marca = f"{m} {fab_nombre.split()[0]}"
                filtro = random.choice(['Con Filtro', 'Sin Filtro'])
                color = random.choice(['Rubio', 'Negro'])
                mentol = random.choice([True, False])
                clase = 'Normal' if (filtro == 'Sin Filtro' or mentol) else random.choice(['Normal', 'Light', 'SuperLight', 'UltraLight'])
                
                # Guardamos mentol como bool en la lista, pero escribimos 't'/'f' en el CSV
                cig = (marca, filtro, color, clase, mentol)
                cigarrillos.append(cig + (round(random.uniform(1.0, 3.0), 2), round(random.uniform(5.0, 8.0), 2), fab_nombre))
                writer.writerow([marca, filtro, color, clase, b_to_pg(mentol), round(random.uniform(0.1, 1.5), 2), round(random.uniform(1.0, 14.0), 2), fab_nombre, 6.5, 2.0, 10, 20])

    # 3. Estancos
    estancos = []
    with open('estancos.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for pais, provs in GEOGRAFIA.items():
            for prov_nombre, locs in provs.items():
                for loc_nombre in locs:
                    for i in range(1, 16):
                        nif = f"NIF-{pais[:3].upper()}-{loc_nombre[:3].upper()}-{i}"
                        estancos.append(nif)
                        direccion = f"{random.choice(CALLES[pais])} {random.randint(1, 2000)}"
                        writer.writerow([nif, random.randint(1000, 9999), f"CP-{random.randint(1000, 9999)}", f"Estanco {loc_nombre} {i}", direccion, loc_nombre, prov_nombre])

    # 4. Almacenes, Compras y Ventas
    with open('almacenes.csv', 'w', newline='', encoding='utf-8') as f_alm, \
         open('compras.csv', 'w', newline='', encoding='utf-8') as f_comp, \
         open('ventas.csv', 'w', newline='', encoding='utf-8') as f_vent:
        w_alm, w_comp, w_vent = csv.writer(f_alm), csv.writer(f_comp), csv.writer(f_vent)
        
        for nif in estancos:
            for cig in random.sample(cigarrillos, random.randint(10, 30)):
                # Convertir mentol a 't'/'f' para el CSV
                row_base = list(cig[:5])
                row_base[4] = b_to_pg(row_base[4])
                
                w_alm.writerow([nif] + row_base + [random.randint(50, 500)])
                
                for i in range(72):
                    fecha = FECHA_INICIO + timedelta(days=i * DIAS_ENTRE_COMPRAS)
                    w_comp.writerow([nif] + row_base + [fecha, random.randint(10, 50), 20.0])
                    w_vent.writerow([nif] + row_base + [fecha + timedelta(days=5), random.randint(1, 8), 6.5])

    print("Archivos CSV generados con éxito. Ahora usan 't'/'f' para booleanos.")

if __name__ == "__main__":
    generar_datos()