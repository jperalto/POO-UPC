require "test/unit"
require "time"
class Administrador
	attr_accessor :arregloDepartamentos, :arregloPropietarios, :arregloRecibosGenerales, :arregloVisitantes
	def initialize
		@arregloDepartamentos = []
		@arregloPropietarios = []
		@arregloRecibosGenerales = []
		@arregloVisitantes = []
	end
	def registrar_dpto(nroDpto, tipo, cant_hab, piso)
		dpto = Departamento.new(nroDpto, tipo, cant_hab, piso)
		arregloDepartamentos.push(dpto)
		return dpto
	end
	def validar_dpto(nroDpto)
		result = false
		for dpto in arregloDepartamentos
			if dpto.nroDpto == nroDpto
				result = true
			end
		end
		return result
	end
	def registrar_propietario(nroDpto, dni, nombre)
		prop = Propietario.new(nroDpto, dni, nombre)
		arregloPropietarios.push(prop)
		return prop
	end
	def registrar_recibo(servicio, mes, año, monto)
		recibo = ReciboGeneral.new(servicio, mes, año, monto)
		arregloRecibosGenerales.push(recibo)
		return recibo
	end
	def generar_cuota_mantenimiento(mes, año)
		acumulador = 0
		for recibo in arregloRecibosGenerales
			if recibo.mes == mes && recibo.año == año
				acumulador = acumulador + recibo.monto
			end
		end
		cuota = acumulador / arregloDepartamentos.size
		return cuota
	end
	def generar_recibo_mantenimiento(cuota, mes, año)
		reciboMantenimiento = ReciboMantenimiento.new(mes, año, cuota)
		for dpto in arregloDepartamentos
			dpto.registrar_recibo_mantenimiento(reciboMantenimiento)
		end
		return reciboMantenimiento
	end
	def validar_recibo_mantenimiento(nroDpto, cod_recibo)
		result = false
		for dpto in arregloDepartamentos
			if dpto.nroDpto == nroDpto
				for reciboMantenimiento in dpto.arreglo_recibos_mantenimiento
					if reciboMantenimiento.cod_recibo == cod_recibo
						result = true
					end
				end
			end
		end
		return result
	end
	def registrar_pago_mantenimiento(nroDpto, cod_recibo, fecha_pago)
		for dpto in arregloDepartamentos
			if dpto.nroDpto == nroDpto
				for reciboMantenimiento in dpto.arreglo_recibos_mantenimiento
					if reciboMantenimiento.cod_recibo == cod_recibo
						reciboMantenimiento.pagar(fecha_pago)
						return reciboMantenimiento
					end
				end
			end
		end
	end
	def validar_visitante(dni)
		result = false
		for visitante in arregloVisitantes
			if visitante.dni == dni
				result = true
			end
		end
		return result
	end
	def registrar_visitante(dni, nombre)
		visitante = Visitante.new(dni,nombre)
		arregloVisitantes.push(visitante)
	end
	def registrar_visita(fecha, nroDpto, dni)
		for visitante in arregloVisitantes
			if visitante.dni == dni
				visita = Visita.new(nroDpto, fecha)
				visitante.registrar_visita(visita)
				return visitante
			end
		end
	end
	def obtener_visitante(dni)
		result = nil
		for visitante in arregloVisitantes
			if visitante.dni == dni
				result = visitante
			end
		end
		return result
	end
	def obtener_departamento(nroDpto)
		for dpto in arregloDepartamentos
			if dpto.nroDpto == nroDpto
				return dpto
			end
		end
	end
end

class ReciboGeneral
	attr_accessor :servicio, :mes, :año, :monto
	def initialize(servicio, mes, año, monto)
		@servicio, @mes, @año, @monto = servicio, mes, año, monto
	end
end

class Visitante
	attr_accessor :dni, :nombre, :arreglo_visitas
	def initialize(dni, nombre)
		@dni, @nombre = dni, nombre
		@arreglo_visitas = []
	end
	def registrar_visita(visita)
		arreglo_visitas.push(visita)
	end
end

class Visita
	attr_accessor :nroDpto, :fecha
	def initialize(nroDpto, fecha)
		@nroDpto = nroDpto
		@fecha = Date.parse(fecha)
	end
end

class ReciboMantenimiento
	attr_accessor :mes, :año, :monto, :estado, :fecha_pago, :cod_recibo
	def initialize(mes, año, monto)
		@mes, @año, @monto = mes, año, monto
		@estado = "Pendiente"
		@fecha_pago = "-"
		@cod_recibo = "#{año}-#{mes}"
	end
	def pagar(fecha)
		@fecha_pago = fecha
		@estado = "Pagado"
	end
end

class Departamento
	attr_accessor :nroDpto, :tipo, :cant_hab, :piso, :arreglo_recibos_mantenimiento
	def initialize(nroDpto, tipo, cant_hab, piso)
		@nroDpto, @tipo, @cant_hab, @piso = nroDpto, tipo, cant_hab, piso
		@arreglo_recibos_mantenimiento = []
	end
	def registrar_recibo_mantenimiento(recibo)
		arreglo_recibos_mantenimiento.push(recibo)
	end
end

class Propietario
	attr_accessor :nroDpto, :dni, :nombre, :arreglo_familiares
	def initialize( nroDpto, dni, nombre)
		@nroDpto, @dni, @nombre = nroDpto, dni, nombre
		@arreglo_familiares = []
	end
	def registrar_familiar(familiar)
		arreglo_familiares.push(familiar)
	end
end

class Familiar
	attr_accessor :dni, :nombre, :parentesco
	def initialize(dni, nombre, parentesco)
		@dni, @nombre, @parentesco = dni, nombre, parentesco
	end
end

class Vista
	def mostrar(msg)
		puts msg
		puts
	end
	def mostrarDpto(dpto)
		puts " Nro Dpto: #{dpto.nroDpto}\n Tipo: #{dpto.tipo}\n Nº Habitaciones: #{dpto.cant_hab}\n Piso: #{dpto.piso}ro"
		puts
	end
	def mostrarPropietario(prop)
		puts " Nro Dpto: #{prop.nroDpto}\n Dni: #{prop.dni}\n Nombre: #{prop.nombre}"
		puts
	end
	def mostrarReciboGeneral(recibo)
		puts " Tipo Serv: #{recibo.servicio}\n Mes: #{recibo.mes}\n Año: #{recibo.año}\n Monto: S/ #{recibo.monto}"
		puts
	end
	def mostrarReciboMantenimiento(reciboMantenimiento)
		puts " Cod Recibo: #{reciboMantenimiento.cod_recibo}\n Mes: #{reciboMantenimiento.mes}\n Año: #{reciboMantenimiento.año}\n Monto: #{reciboMantenimiento.monto}\n Estado: #{reciboMantenimiento.estado}\n Fecha de pago: #{reciboMantenimiento.fecha_pago}"
		puts
	end
	def mostrarVisitante(visitante)
		puts " Dni: #{visitante.dni}\n #{visitante.nombre}\n Visitas:"
		for visita in visitante.arreglo_visitas
			puts "  - #{visita.fecha} #{visita.nroDpto}"
		end
	end
	def mostrar_visitas_por_fecha(arr_visitantes, fecha)
		date = Date.parse(fecha)
		for visitante in arr_visitantes
			for visita in visitante.arreglo_visitas
				if visita.fecha == date
					puts "  #{visitante.nombre} visitó al dpto #{visita.nroDpto}"
				end
			end
		end
		puts
	end
	def mostrar_visitas_por_rango(arr_visitantes, fecha_inicio, fecha_fin)
		for visitante in arr_visitantes
			for visita in visitante.arreglo_visitas
				if visita.fecha >= fecha_inicio && visita.fecha <= fecha_fin
					puts "  #{visitante.nombre} visitó al dpto #{visita.nroDpto}"
				end
			end
		end
		puts
	end
end

class Controlador
	attr_accessor :vista, :adm
	def initialize(vista, adm)
		@vista, @adm = vista, adm
	end
	def registrarDpto(nroDpto, tipo, cant_hab, piso)
		existe = adm.validar_dpto(nroDpto)
		if !existe
			begin
	    	    dpto = adm.registrar_dpto(nroDpto, tipo, cant_hab, piso)
				vista.mostrar("Éxito. Se registró el departamento #{nroDpto}:")
		      rescue Exception => e
		      	vista.mostrar(e.message)
	      	end
	     end
	end

	def registrarPropietario(nroDpto, dni, nombre)
		existe = adm.validar_dpto(nroDpto)
		if existe
			begin
				prop = adm.registrar_propietario(nroDpto, dni, nombre)
				vista.mostrar("Éxito. Se registró al propietario #{nombre}:")
			rescue Exception => e
				vista.mostrar(e.message)
			end
		end
	end
	def registrarReciboGeneral(servicio, mes, año, monto)
		recibo = adm.registrar_recibo(servicio, mes, año, monto)
		vista.mostrar("Éxito. Se registró el recibo general:")
		#vista.mostrarReciboGeneral(recibo)
	end
	def generarReciboMantenimiento(mes, año)
		cuota = adm.generar_cuota_mantenimiento(mes, año)
		reciboMantenimiento = adm.generar_recibo_mantenimiento(cuota, mes, año)
		vista.mostrar("Éxito. Se generó el recibo de Mantenimiento #{reciboMantenimiento.cod_recibo}:")
		#vista.mostrarReciboMantenimiento(reciboMantenimiento)
	end
	def registrarPagoMantenimiento(nroDpto, cod_recibo, fecha_pago)
		existe_recibo = adm.validar_recibo_mantenimiento(nroDpto, cod_recibo)
		if existe_recibo
			recibo_actualizado = adm.registrar_pago_mantenimiento(nroDpto, cod_recibo, fecha_pago)
			vista.mostrar("Éxito. Se registró el pago para el dpto #{nroDpto}:")
			#vista.mostrarReciboMantenimiento(recibo_actualizado)
		else
			vista.mostrar("Error. El recibo aún no ha sido generado.")
		end
	end
	def registrarVisita(fecha, nroDpto, dni, nombre)
		existe = adm.validar_visitante(dni)
		if existe
			visitante_actualizado = adm.registrar_visita(fecha, nroDpto, dni)
			vista.mostrar("Éxito. Se registró una nueva visita:")
			#vista.mostrarVisitante(visitante_actualizado)
		else
			adm.registrar_visitante(dni, nombre)
			visitante_actualizado = adm.registrar_visita(fecha, nroDpto, dni)
			vista.mostrar("Éxito. Se registró un nuevo visitante:")
			#vista.mostrarVisitante(visitante_actualizado)
		end
	end
	def consultarVisitasPorFecha(fecha)
		arr_visitantes = adm.arregloVisitantes
		vista.mostrar("Visitas del #{fecha}:")
		vista.mostrar_visitas_por_fecha(arr_visitantes, fecha)
	end
	def consultarVisitaPorRangoFecha(fecha_inicio, fecha_fin)
		inicio = Date.parse(fecha_inicio)
		fin = Date.parse(fecha_fin)
		arr_visitantes = adm.arregloVisitantes
		vista.mostrar("Visitas del #{fecha_inicio} al #{fecha_fin}:")
		vista.mostrar_visitas_por_rango(arr_visitantes, inicio, fin)
	end
	def consultarVisitaPorDni(dni)
		visitante = adm.obtener_visitante(dni)
		vista.mostrar("Busqueda visitas por dni #{visitante.dni}:")
		vista.mostrarVisitante(visitante)
	end
end


condominio1 = Administrador.new
vista = Vista.new
controlador = Controlador.new(vista, condominio1)
controlador.registrarDpto("D101", "Flat", 3, 1)
controlador.registrarDpto("D101", "Loft", 1, 1)
controlador.registrarDpto("D101", "Loft", 1, 1)
controlador.registrarDpto("D102", "Loft", 1, 1)
controlador.registrarDpto("D102", "Loft", 1, 1)
controlador.registrarDpto("D201", "Flat", 3, 1)
controlador.registrarDpto("D202", "Flat", 3, 1)
controlador.registrarDpto("D301", "Duplex", 5, 1)
controlador.registrarDpto("D302", "Duplex", 5, 1)
controlador.registrarPropietario("D101", "08167348", "Alex Ramirez")
controlador.registrarPropietario("D102", "14628149", "Lucia Fernandez")
controlador.registrarPropietario("D201", "15546281", "Jose Castañeda")
controlador.registrarPropietario("D202", "95128149", "Andre Guerrero")
controlador.registrarPropietario("D301", "63932343", "Fernanda Galvez")
controlador.registrarPropietario("D302", "74343123", "Katy Perez")
controlador.registrarReciboGeneral("Agua", 9, 2019, 1320)
controlador.registrarReciboGeneral("Luz", 9, 2019, 1560)
controlador.registrarReciboGeneral("Vigilancia", 9, 2019, 1200)
controlador.registrarReciboGeneral("Areas Comunes", 9, 2019, 1800)
controlador.generarReciboMantenimiento(9,2019)
controlador.registrarPagoMantenimiento("D101", "2019-9", "2019-09-12")
controlador.registrarPagoMantenimiento("D202", "2019-9", "2019-09-18")
controlador.registrarPagoMantenimiento("D301", "2019-9", "2019-10-11")
controlador.registrarVisita("2019-10-03", "D101", "93414553", "Frank Soto")
controlador.registrarVisita("2019-10-03", "D102", "91232115", "Luisa Garcia")
controlador.registrarVisita("2019-10-04", "D101", "93414543", "Hans Ramos")
controlador.registrarVisita("2019-10-04", "D102", "93414153", "Eduardo Perez")
controlador.registrarVisita("2019-10-05", "D101", "93424553", "Andre Guerrero")
controlador.registrarVisita("2019-10-06", "D102", "91232515", "Antony Saenz")
controlador.registrarVisita("2019-10-06", "D302", "93424553", "Andre Guerrero")
controlador.consultarVisitasPorFecha("2019-10-06")
controlador.consultarVisitaPorRangoFecha("2019-10-04", "2019-10-05")
controlador.consultarVisitaPorDni("93424553")
