import csv
import random
from datetime import date, timedelta

# --- CONFIGURACIÓN DE DATOS ---
PAISES = ["Chile", "Argentina", "Reino Unido", "Alemania", "Japon"]
# 3 años exactos hacia atrás
FECHA_INICIO = date.today() - timedelta(days=3 * 365) 

def generar_datos():
    print("Iniciando generación de datos...")
    
    # Función auxiliar para convertir booleano a formato Postgres ('t'/'f')
    def b_to_pg(val):
        return 't' if val else 'f'
    
    # 1. Fabricantes (10 fabricantes por país -> 50 total)
    fabricantes_list = []
    with open('fabricantes.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for pais in PAISES:
            for i in range(1, 11):
                nombre = f"{pais} Tabacco Co {i}"
                fabricantes_list.append(nombre)
                writer.writerow([nombre, pais])

    # 2. Cigarrillos (10 tipos distintos por fabricante -> 500 total)
    cigarrillos = []
    cig_pk_set = set() # Set para evitar colisiones en la Clave Primaria
    
    with open('cigarrillos.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for fab in fabricantes_list:
            # Para asegurar que la marca es única por fabricante, la incrustamos en el nombre
            marcas_base = [f"Gold {fab.replace(' ', '')}", f"Silver {fab.replace(' ', '')}"]
            
            tipos_generados = 0
            while tipos_generados < 10:
                marca = random.choice(marcas_base)
                filtro = random.choice(['Con Filtro', 'Sin Filtro'])
                color = random.choice(['Rubio', 'Negro'])
                mentol = random.choice([True, False])
                
                # Supuestos 8 y 9: Sin filtro o mentolados siempre son clase Normal
                if mentol or filtro == 'Sin Filtro':
                    clase = 'Normal'
                else:
                    clase = random.choice(['Normal', 'Light', 'SuperLight', 'UltraLight'])
                
                # Definición estricta de la PK
                pk = (marca, filtro, color, clase, mentol)
                
                if pk not in cig_pk_set:
                    cig_pk_set.add(pk)
                    nicotina = round(random.uniform(0.1, 1.5), 2)
                    alquitran = round(random.uniform(1.0, 14.0), 2)
                    p_venta = round(random.uniform(4.0, 9.0), 2)
                    p_costo = round(p_venta * 0.6, 2) # Costo coherente
                    
                    # Guardamos la tupla base para usarla en almacenes/compras/ventas
                    cigarrillos.append(pk)
                    writer.writerow([marca, filtro, color, clase, b_to_pg(mentol), nicotina, alquitran, fab, p_venta, p_costo, 10, 20])
                    tipos_generados += 1

    # 3. Estancos (10 provincias, 10-15 localidades/provincia, 15 estancos/localidad)
    estancos = []
    with open('estancos.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        estanco_id = 1
        
        # Distribuimos 10 provincias entre los 5 países (2 por país)
        for pais in PAISES:
            for prov_idx in range(1, 3):
                prov_nombre = f"Provincia {prov_idx} {pais}"
                num_localidades = random.randint(10, 15)
                
                for loc_idx in range(1, num_localidades + 1):
                    loc_nombre = f"Localidad {loc_idx} {prov_nombre}"
                    
                    for _ in range(15): # Exactamente 15 estancos por localidad
                        nif = f"NIF-{estanco_id:06d}" # NIF garantizado único
                        estancos.append(nif)
                        num_exp = random.randint(100, 999) # Puede repetirse
                        cp = f"CP-{random.randint(1000, 9999)}"
                        nombre_estanco = f"Estanco {estanco_id}"
                        direccion = f"Calle Comercial {random.randint(1, 1000)}"
                        
                        writer.writerow([nif, num_exp, cp, nombre_estanco, direccion, loc_nombre, prov_nombre])
                        estanco_id += 1

    # 4. Almacenes, Compras y Ventas
    with open('almacenes.csv', 'w', newline='', encoding='utf-8') as f_alm, \
         open('compras.csv', 'w', newline='', encoding='utf-8') as f_comp, \
         open('ventas.csv', 'w', newline='', encoding='utf-8') as f_vent:
        
        w_alm, w_comp, w_vent = csv.writer(f_alm), csv.writer(f_comp), csv.writer(f_vent)
        
        for nif in estancos:
            # 10 a 30 almacenes (tipos de cigarrillos) por estanco
            num_almacenes = random.randint(10, 30)
            
            # random.sample garantiza no escoger el mismo cigarrillo 2 veces para el mismo estanco
            cigs_seleccionados = random.sample(cigarrillos, num_almacenes)
            
            for cig in cigs_seleccionados:
                row_base = list(cig)
                row_base[4] = b_to_pg(row_base[4]) # mentol bool a string 't'/'f'
                
                stock_inicial = random.randint(50, 500)
                w_alm.writerow([nif] + row_base + [stock_inicial])
                
                # 3 años, promedio 2 al mes = 72 iteraciones separadas por 15 días
                for iteracion in range(72):
                    fecha_c = FECHA_INICIO + timedelta(days=iteracion * 15)
                    # La venta ocurre unos días después para evitar colisión de fecha con la compra,
                    # aunque están en tablas distintas, ayuda a la línea temporal lógica.
                    fecha_v = fecha_c + timedelta(days=5) 
                    
                    c_comp = random.randint(10, 50)
                    p_comp = round(random.uniform(2.0, 5.0), 2)
                    w_comp.writerow([nif] + row_base + [fecha_c, c_comp, p_comp])
                    
                    # Ventas al detalle: Coherencia de volumen (no vende más del lote de compra)
                    c_vend = random.randint(1, c_comp) 
                    p_vend = round(p_comp * 1.5, 2)
                    w_vent.writerow([nif] + row_base + [fecha_v, c_vend, p_vend])

    print("Archivos CSV generados con éxito.")
    print(f"Total de Estancos generados: {len(estancos)}")

if __name__ == "__main__":
    generar_datos()