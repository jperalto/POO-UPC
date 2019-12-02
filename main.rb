require "test/unit"
require "time"
class Administrador
	attr_accessor :arregloDepartamentos, :arregloRecibosGenerales, :arregloVisitantes
	def initialize
		@arregloDepartamentos = []
		@arregloRecibosGenerales = []
		@arregloVisitantes = []
	end
	def registrar_dpto(departamento)
		arregloDepartamentos.push(departamento)
	end
	def registrar_recibo(servicio, mes, año, monto)
		recibo = ReciboGeneral.new(servicio, mes, año, monto)
		arregloRecibosGenerales.push(recibo)
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
	def generar_recibo_mantenimiento(mes, año)
		monto = generar_cuota_mantenimiento(mes, año)
		recibo = ReciboMantenimiento.new(mes, año, monto)
		for dpto in arregloDepartamentos
			dpto.registrar_recibo_mantenimiento(recibo)
		end
		return recibo
	end
	def registrar_pago_mantenimiento(nroDpto, mes, año, fecha_pago)
		for dpto in arregloDepartamentos
			if dpto.nroDpto == nroDpto
				for recibo in dpto.arreglo_recibos_mantenimiento
					if recibo.mes == mes && recibo.año == año
						recibo.pagar(fecha_pago)
						return recibo
					end
				end
			end
		end
	end
	def registrar_visitante(visitante)
		arregloVisitantes.push(visitante)
	end
	def registrar_visita(fecha, nroDpto, dni, nombre)
		date = Date.parse(fecha)
		existe = false
		for visitante in arregloVisitantes
			if visitante.dni == dni
				existe = true
				visita = Visita.new(nroDpto, date)
				visitante.registrar_visita(visita)
			end
		end
		if existe == false
			visitante = Visitante.new(dni, nombre)
			visita = Visita.new(nroDpto, date)
			visitante.registrar_visita(visita)
			registrar_visitante(visitante)
		end
	end
	def consultar_visita_fecha(fecha)
		date = Date.parse(fecha)
		for visitante in arregloVisitantes
			for visita in visitante.arregloVisitas
				if visita.fecha == date
					puts "#{visitante.nombre} visitó al dpto #{visita.nroDpto}"
				end
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
	attr_accessor :dni, :nombre, :arregloVisitas
	def initialize(dni, nombre)
		@dni, @nombre = dni, nombre
		@arregloVisitas = []
	end
	def registrar_visita(visita)
		arregloVisitas.push(visita)
	end
end

class Visita
	attr_accessor :nroDpto, :fecha
	def initialize(nroDpto, fecha)
		@nroDpto = nroDpto
		@fecha = fecha
	end
end

class ReciboMantenimiento
	attr_accessor :mes, :año, :monto, :estado, :fecha_pago
	def initialize(mes, año, monto)
		@mes, @año, @monto = mes, año, monto
		@estado = "Pendiente"
		@fecha_pago = "-"
	end
	def pagar(fecha)
		@fecha_pago = fecha
		@estado = "Pagado"
	end
end

class Departamento
	attr_accessor :nroDpto, :codigo_propietario, :arreglo_recibos_mantenimiento
	def initialize(nroDpto, codigo_propietario)
		@nroDpto, @codigo_propietario = nroDpto, codigo_propietario
		@arreglo_recibos_mantenimiento = []
	end
	def registrar_recibo_mantenimiento(recibo)
		arreglo_recibos_mantenimiento.push(recibo)
	end
end

class Propietario
	attr_accessor :codigo_propietario, :dni, :nombre, :arreglo_familiares
	def initialize(codigo_propietario, dni, nombre)
		@codigo_propietario, @dni, @nombre = codigo_propietario, dni, nombre
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


class TestCondominio < Test::Unit::TestCase
	def setup
		@condominio1 = Administrador.new
		@propietario1 = Propietario.new("P001", 81491462, "Alex Ramirez")
		@propietario2 = Propietario.new("P002", 14628149, "Lucia Fernandez")
		@propietario3 = Propietario.new("P003", 15546281, "Jose Castañeda")
		@propietario4 = Propietario.new("P004", 95128149, "Andre Guerrero")
		@propietario5 = Propietario.new("P005", 63932343, "Fernanda Galvez")
		@propietario6 = Propietario.new("P006", 74343123, "Katy Perez")
		@dpto1 = Departamento.new(101, @propietario1.codigo_propietario)
		@dpto2 = Departamento.new(102, @propietario2.codigo_propietario)
		@dpto3 = Departamento.new(201, @propietario3.codigo_propietario)
		@dpto4 = Departamento.new(202, @propietario4.codigo_propietario)
		@dpto5 = Departamento.new(301, @propietario5.codigo_propietario)
		@dpto6 = Departamento.new(302, @propietario6.codigo_propietario)
		@familiar1 = Familiar.new(92341142, "Carlos Saenz", "Hermano")
		@familiar2 = Familiar.new(94523123, "Eusebia Rosas", "Mamá")
		@familiar3 = Familiar.new(41234555, "Fernando Lopez", "Papá")
		@familiar4 = Familiar.new(13413462, "Jair Fajardo", "Hermano")
		@familiar5 = Familiar.new(51235124, "Josefa Ruiz", "Hija")
		@familiar6 = Familiar.new(41213452, "Luis Perez", "Esposo")
		@propietario1.registrar_familiar(@familiar1)
		@propietario2.registrar_familiar(@familiar2)
		@propietario3.registrar_familiar(@familiar3)
		@propietario4.registrar_familiar(@familiar4)
		@propietario5.registrar_familiar(@familiar5)
		@propietario6.registrar_familiar(@familiar6)
		@condominio1.registrar_dpto(@dpto1)
		@condominio1.registrar_dpto(@dpto2)
		@condominio1.registrar_dpto(@dpto3)
		@condominio1.registrar_dpto(@dpto4)
		@condominio1.registrar_dpto(@dpto5)
		@condominio1.registrar_dpto(@dpto6)
		@condominio1.registrar_recibo("Agua", 8, 2019, 1320)
		@condominio1.registrar_recibo("Luz", 8, 2019, 1582)
		@condominio1.registrar_recibo("Vigilancia", 8, 2019, 2048)
		@condominio1.registrar_recibo("Limpieza", 8, 2019, 850)
		@condominio1.registrar_recibo("Areas Comunes", 8, 2019, 520)
		@condominio1.generar_recibo_mantenimiento(8, 2019)
		@visitante1 = Visitante.new(12452412, "Frank Soto")
		@condominio1.registrar_visitante(@visitante1)
		@condominio1.registrar_visita("2019-09-01", 101, 12452412, "Frank Soto")
		@condominio1.registrar_visita("2019-09-01", 101, 12388412, "Carla Fuentes")
		@condominio1.registrar_visita("2019-09-01", 301, 98231234, "Pedro Aquino")
	end
	def testRegistrarReciboGeneral
		@condominio1.registrar_recibo("Agua", 7, 2019, 1320)
		puts
		puts "--------- RegistrarReciboGeneral ---------"
		for recibo in @condominio1.arregloRecibosGenerales
			puts "#{recibo.servicio} #{recibo.mes} #{recibo.año} #{recibo.monto}"
		end
		puts
	end
	def testGenerarReciboMantenimiento
		condominio1 = @condominio1
		@condominio1.registrar_recibo("Agua", 9, 2019, 1320)
		@condominio1.registrar_recibo("Luz", 9, 2019, 1582)
		@condominio1.registrar_recibo("Vigilancia", 9, 2019, 2048)
		@condominio1.registrar_recibo("Limpieza", 9, 2019, 850)
		@condominio1.registrar_recibo("Areas Comunes", 9, 2019, 520)
		mes = 9
		año = 2019
		recibo = condominio1.generar_recibo_mantenimiento(mes, año)
		puts
		puts "--------- GenerarReciboMantenimiento ---------"
		puts "#{recibo.mes} #{recibo.año} #{recibo.monto} #{recibo.estado} #{recibo.fecha_pago}"
		for dpto in condominio1.arregloDepartamentos
			puts "Recibos Dpto: #{dpto.nroDpto}"
			for recibo in dpto.arreglo_recibos_mantenimiento
				puts "  #{recibo.mes} #{recibo.año} #{recibo.monto} #{recibo.estado} #{recibo.fecha_pago}"
			end
		end
		puts
	end
	def testRegistrarPagoMantenimiento
		condominio1 = @condominio1
		dpto = 101
		mes = 8
		año = 2019
		fecha_pago = "01/09/2019"
		puts
		puts "--------- RegistrarPagoMantenimiento ---------"
		recibo = condominio1.registrar_pago_mantenimiento(dpto, mes, año, fecha_pago)
		puts "Recibo Actualizado Dpto: #{dpto}"
		puts "#{recibo.mes} #{recibo.año} #{recibo.monto} #{recibo.estado} #{recibo.fecha_pago}"
	end
	def testRegistrarVisita
		condominio1 = @condominio1
		puts
		puts "--------- RegistrarVisita (Visitante ya registrado) ---------"
		condominio1.registrar_visita("2019-09-10", 202, 12452412, "Frank Soto")
		for visitante in condominio1.arregloVisitantes
			puts "Visitante #{visitante.nombre} (dni #{visitante.dni})"
			for visita in visitante.arregloVisitas
				puts "   #{visita.nroDpto} #{visita.fecha}"
			end
		end
		puts
		puts "--------- RegistrarVisita (Nuevo Visitante) ---------"
		condominio1.registrar_visita("2019-09-15", 101, 43123323, "Carlos Gutierrez")
		for visitante in condominio1.arregloVisitantes
			puts "Visitante #{visitante.nombre} (dni #{visitante.dni})"
			for visita in visitante.arregloVisitas
				puts "   #{visita.nroDpto} #{visita.fecha}"
			end
		end
	end
	def testConsultarVisitaFecha
		condominio1 = @condominio1
		puts
		puts "--------- ConsultarVisitaFecha ---------"
		condominio1.consultar_visita_fecha("01/09/2019")
		puts
	end
end