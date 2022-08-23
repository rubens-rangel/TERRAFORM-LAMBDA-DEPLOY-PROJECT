package com.crud.Services;


import com.crud.Domain.Todo;
import com.crud.Repository.TodoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;

@Service
public class DBService {

    @Autowired
    private TodoRepository todoRepository;

    public void instanciaBaseDeDados() {

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        Todo t1 = new Todo(null, "Estudar", "Estudar SpringBoot 2.x",
                LocalDateTime.parse("25/03/2022 15:35", formatter), false);
        Todo t2 = new Todo(null, "Ler", "Ler livro de desenvolvimento pessoal",
                LocalDateTime.parse("25/03/2022 15:35", formatter), false);
        Todo t3 = new Todo(null, "Execicios", "Praticar exercicios fisicos",
                LocalDateTime.parse("12/05/2022 15:35", formatter), true);
        Todo t4 = new Todo(null, "Meditar", "Meditar durante 30 minutos pela manha",
                LocalDateTime.parse("13/05/2022 15:35", formatter), false);

        todoRepository.saveAll(Arrays.asList(t1, t2, t3, t4));

        todoRepository.saveAll(Arrays.asList(t1));

    }
}


