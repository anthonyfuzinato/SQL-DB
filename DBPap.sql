create table Utilizador(
	nif char(9) not null unique primary key,
	email varchar(100) not null unique primary key check(email like'%@%.%'),
	cod_utilizador char(3) check(cod_utilizador in('a','p','adm')),
	nome varchar(100) not null check((len(nome)>5) and charindex(' ',nome)>0),
	data_criacao date default getdate(),
	senha varchar(50) not null check((len(senha)>8) and (senha not like'% %')),
	codigo_postal char(8) not null check (codigo_postal like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]'),
	ativo bit default 1,
);

create table aluno(
	nif char(9) references utilizador(nif),
	peso decimal(5,2) check(peso>0),
	altura decimal(4,2),
	imc decimal(3,1),
	data_nascimento date not null,
	idade as (
		datediff(year, data_nascimento, getdate())
		- case
			when dateadd(year, datediff(year, data_nascimento, getdate()), data_nascimento) > getdate()
				then 1
			else 0
		  end
		),
);

create table personaltrainer (
    
    cod_pt char(6) not null primary key check (cod_pt like 'P[0-9][0-9][0-9][0-9][0-9]'),
    nif varchar(35) not null references utilizador(nif),
    especialidade text not null,
    formacao text not null,
    experiencia text not null,
    avaliacao decimal(2,1) 
        check (avaliacao between 0 and 5),
    preco smallmoney
);


create table admin(
	id_admin int identity(0,1) primary key,
	nif char(9) references utilizador(nif),
	super bit default 0
);

create table treino (
    id_treino int not null identity(1,1) primary key,
    nif char(6) not null references aluno(nif),  
    data_treino date default getdate() check (data_treino <= getdate()),
    duracao time not null check (duracao > '00:00'),
    calorias decimal(5,2),
    treino_personalizado bit default 0
);

create table exercicio (
    id_exercicio int not null identity(1,1) primary key,
    designacao varchar(100) not null,
    repeticoes smallint not null,
    series smallint not null,
    carga decimal(5,2) not null,
    peso decimal(5,2)
);

create table conquista (
    id_conquista int not null identity(1,1) primary key,
    nome varchar(100) not null,
    descricao text not null,
    icone varchar(100) not null,
    nivel_conquista varchar(7) not null check (nivel_conquista in ('ouro', 'prata', 'bronze'))
);


create trigger Atualizar_IMC_Automatico
on aluno
after update
as
begin
    if update(peso) or update(altura)
    begin
        update aluno_atualizado
        set imc = round(novos_dados.peso / (novos_dados.altura * novos_dados.altura), 1)
        from aluno aluno_atualizado
        inner join inserted novos_dados 
            on aluno_atualizado.nif = novos_dados.nif;
    end
end;

create trigger Calcular_Calorias
on treino
after insert, update
as
begin
    declare @met decimal(4,2) = 8.0; 

    update treino_atualizado
    set calorias =
        @met
        * aluno_relacionado.peso
        * (
            datepart(hour, novos_valores.duracao) * 60 +
            datepart(minute, novos_valores.duracao)
          )
    from treino treino_atualizado
    inner join inserted novos_valores
        on treino_atualizado.id_treino = novos_valores.id_treino
    inner join aluno aluno_relacionado
        on aluno_relacionado.nif = novos_valores.cod_aluno;
end;

