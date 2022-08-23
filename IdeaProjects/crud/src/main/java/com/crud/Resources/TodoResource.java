package com.crud.Resources;

import com.crud.Domain.Todo;
import com.crud.Services.TodoService;
import org.hibernate.ObjectNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping(value = "/todos")
public class TodoResource {

    @Autowired
    private TodoService service;

    @GetMapping(value = "/{id}")
    public ResponseEntity<Todo> findById(@PathVariable Integer id) {
        Todo obj = service.findById(id);
        return ResponseEntity.ok().body(obj);
    }

    @GetMapping(value = "/open")
    public ResponseEntity<List<Todo>> ListOpen() {
        List<Todo> obj = service.findAllOpen();
        return ResponseEntity.ok().body(obj);
    }

    @GetMapping(value = "/closed")
    public ResponseEntity<List<Todo>> ListClosed() {
        List<Todo> obj = service.findAllClosed();
        return ResponseEntity.ok().body(obj);
    }

    @GetMapping
    public ResponseEntity<List<Todo>> findALll() {
        List<Todo> obj = service.findAll();
        return ResponseEntity.ok().body(obj);
    }

    @PutMapping(value = "/{id}")
    public ResponseEntity<Todo> update(@PathVariable Integer id, @RequestBody Todo todo) {
        todo = service.update(id, todo);
        return ResponseEntity.ok().body(todo);
    }


    @PostMapping
    public ResponseEntity<Todo> create(@RequestBody Todo obj) {
        obj = service.create(obj);
        URI uri = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{id}").buildAndExpand(obj.getId()).toUri();
        return ResponseEntity.created(uri).build();
    }

    @DeleteMapping(value = "/{id}")
    public ResponseEntity<Void> DeleteById(@PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
