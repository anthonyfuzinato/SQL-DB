create table Utilizador(
	nif varchar(9) primary key,
	email varchar(100) not null unique check(email like'%@%.%'),
	perfil char(3) check(cod_utilizador in('a','p')),
	nome varchar(100) not null check((len(nome)>5) and charindex(' ',nome)>0),
	data_criacao date default getdate(),
	senha varchar(50) not null,
	morada varchar(100) not null,
	codigo_postal char(8) not null check (codigo_postal like '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]'),
	ativo bit default 1,
	token varchar(max),
	validade_token date() default dateadd(day,getdate(),1)
);

create table aluno(
	id int identity (1000,1) primary key,
	nif varchar(9) references utilizador(nif),
	peso decimal(5,2) check(peso>0),
	altura decimal(4,2),
	imc decimal(3,1),
	data_nascimento date not null,
	sexo char(1) check(sexo in ('f','m')
);

create table PT (
    id int identity (2000,1) primary key,
    nif varchar(9) not null references utilizador(nif),
    formacao text not null,
    experiencia text,
    avaliacao decimal(2,1) 
        check (avaliacao between 0 and 5) default 0,
    preco smallmoney
);


create table Administrador(
	id int identity (3000,1) primary key,
	nif char(9) references utilizador(nif),
	super bit default 0
);

create table Treino (
    id_treino int identity(1,1) primary key,
    cod_aluno char(6) not null references aluno(cod_aluno),  
    data_treino date default getdate() check (data_treino <= getdate()),
    duracao time not null check (duracao > '00:00'),
    calorias decimal(5,2),
    treino_personalizado bit default 0,
	descrição varchar(max),
);

create table Exercicio (
    id_exercicio int identity(1,1) primary key,
    designacao varchar(100) not null,
    repeticoes smallint not null,
    series smallint not null,
    carga decimal(5,2) not null,
    peso decimal(5,2) not null,
);

create table Conquista (
    id_conquista int identity(1,1) primary key,
    nome varchar(100) not null,
    descricao text not null,
    icone varchar(100) not null,
    nivel_conquista varchar(7) not null check (nivel_conquista in ('ouro', 'prata', 'bronze'))
);

create table Ginasio (
    id_ginasio int identity(0,1) primary key,
    nome varchar(100) not null,
    localizacao varchar(250) not null
)

create table Plano_personalizado(
    id_plano int identity(0,1) primary key,
    objetivo varchar (150),
    nivel char(1) check (nivel between 1 and 3),
    duracao int check (duracao >0),
    descricao text not null
)

create table Exercicio_Treino(
    id_exercicio_treino int identity(0,1) primary key,
    id_exercicio int references Exercicio(id_exercicio),
    id_treino int references Treino(id_treino)
)

create table Plano_treino_Aluno (
    id_t_a int identity(0,1),
    id_plano int references Plano_personalizado(id_plano),
    cod_aluno char(6) not null references aluno(cod_aluno),
    dta_inicio date,
    dta_fim date
)

create table Aluno_Conquista(
    id_aluno_conquista int identity(0,1) primary key, 
    id_conquista int not null references Conquista(id_conquista),
    cod_aluno char(6) not null references aluno(cod_aluno),
    dta date default getdate()
)

create table Pt_Ginasio(
    id_pt_ginasio int identity(0,1) primary key,
    cod_pt char(6) not null references PT(cod_aluno),
    id_ginasio int not null references Ginasio(id_ginasio),
    data_admissao date
)

create table Treino_Plano(
    id_treino_plano int identity(0,1) primary key,
    id_plano int not null references Plano_personalizado(id_plano),
    id_treino int not null references Treino(id_treino),
    feito_correto bit default 0
)

create table Adm_Ginasio(
    id_adm_ginasio int identity (0,1) primary key,
    cod_admin char(6) not null references Administrador(cod_admin),
    id_ginasio int references Ginasio(id_ginasio),
    dta_atribuicao date,
    permissao_total bit default 0
)

create table Especialidade(
    id_especialidade int identity(0,1) primary key,
    nome varchar(100) not null,
    descricao text
)

create table Pt_Especialidade(
    id_pt_especialidade int identity (0,1) primary key,
    cod_pt char(6) not null references aluno(cod_aluno),
    id_especialidade int references Especialidade(id_especialidade),
    certificado bit default 0,
    data_certificacao date
)

create table Nome_exercicios(
    id_nome_exercicio int identity(0,1) primary key,
    nome varchar(50) not null,
    grupo_muscular varchar(50) not null,
    equipamento varchar(50),
    descricao text not null,
    dificuldade varchar(11) not null check (dificuldade in ('fácil','intermédio','dificil'))
)

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




