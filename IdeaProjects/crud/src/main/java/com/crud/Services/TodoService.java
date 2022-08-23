package com.crud.Services;

import com.crud.Domain.Todo;
import com.crud.Repository.TodoRepository;
import com.crud.Services.exceptions.ObjectNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;


@Service
public class TodoService {

    @Autowired
    private TodoRepository repository;

    public Todo findById(Integer id) {
        Optional<Todo> obj = repository.findById(id);
        String text = "Objeto nao encontrado! Id: " + id + ", Tipo: " + Todo.class.getName();
        return obj.orElseThrow(() -> new ObjectNotFoundException(text));

    }

    public List<Todo> findAllOpen() {
        List<Todo> list = repository.findAllOpen();
        return list;
    }

    public List<Todo> findAllClosed() {
        List<Todo> list = repository.findAllClosed();
        return list;
    }

    public List<Todo> findAll() {
        List<Todo> list = repository.findAll();
        return list;
    }

    public Todo create(Todo obj) {
        obj.setId(null);
        return repository.save(obj);
    }

    public void delete(Integer id) {
        repository.deleteById(id);
    }

    public Todo update(Integer id, Todo todo) {
        Todo newobj = findById(id);
        updateData(newobj, todo);
        return repository.save(newobj);
    }

    private void updateData(Todo newobj, Todo obj) {
        newobj.setTitulo(obj.getTitulo());
        newobj.setDescricao(obj.getDescricao());
        newobj.setDataParaFinalizar(obj.getDataParaFinalizar());
        newobj.setFinalizado(obj.getFinalizado());
    }

}
