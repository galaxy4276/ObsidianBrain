---
tags: react
---

![[reactjs-javascript-programming-programming-language-hd-wallpaper-preview.jpg]]

React 를 이용하면서 DI 패턴을 사용해야하는 이유와 방법에 대해 서술하겠습니다.

## 컴포넌트 내 비즈니스 로직이 있으면 안되는 이유

- React 는 사용자 인터페이스를 만들기 위한 라이브러리이며, 이러한 정의는 컴포넌트에 비즈니스 로직을 넣지 말아야 한다는 것이다,
- 비즈니스 로직을 포함하는 컴포넌트는 읽고, 유지하고, 테스트하기가 어렵다.
- 컴포넌트에서 비즈니 로직을 추출하는 것은 재사용할 수 있는 훌룡한 아이디어이다.

결론적으로, 컴포넌트에서 비즈니스 로직을 빼내면 외부 클래스나 함수 등 어딘가에 작성해야 합니다.

이 때 바로 의존성 주입(Dependency Injection)을 이용하면 되는 것입니다.

<aside>
💡 의존성 주입 패턴을 이용하면 원본 코드를 변경하지 않고도 쉽게 기능을 교체 및 확장할 수 있습니다.

</aside>

## React 에서 DI 를 구현해보자!

할 일 목록을 관리하 React 애플리케이션을 개발한다 가정하고, 컴포넌트가 렌더링 될 때 일부 API에서 할일 목록을 가져와야 할 때, 컴포넌트 내에서 비즈니스 로직을 작성하고 싶지 않으므로, API 호출을 수행하는 서비스를 컴포넌트 내에서 사용할 수 있습니다.

아래 자료는 예시에 대한 다이어그램입니다.

```jsx
Component                  Service                       API
                  |                          |                          |
                  |                          |                          |
                  |    Request Data          |                          |
                  |------------------------->|                          |
                  |                          |                          |
                  |                          |  Retrieve Data from API  |
                  |                          |------------------------->|
                  |                          |                          |
                  |                          |    Process Data          |
                  |                          |<-------------------------|
                  |                          |                          |
                  |  Receive Data            |                          |
                  |<-------------------------|                          |
                  |                          |                          |
```

실제 코드 시점은 다음과 같습니다.

```jsx
import React from 'react';
import TodoService from './TodoService';
import TodoList from './TodoList';

function App() {
  return <TodoList todoService={TodoService} />;
}

export default App;
```

```jsx
import React, { useState, useEffect } from 'react';
import TodoService from './TodoService';

function TodoList() {
  const [todos, setTodos] = useState([]);

  useEffect(() => {
    async function fetchTodos() {
      try {
        const todos = await TodoService.getTodos(); // Call TodoService to get todos
        setTodos(todos);
      } catch (error) {
        console.error(error);
      }
    }
    fetchTodos();
  }, []);

  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  );
}

export default TodoList;
```

하지만 위와 같은 구조는 다음과 같은 문제점이 존재합니다.

> 컴포넌트가 중첩될 수록 과도한 Prop Drilling 이 발생한다.
> 

위와 같은 문제점을 방지하기 위해 React 의 Context API 를 사용하여 DI 를 구현해보겠습니다.

```jsx
import React from 'react';
import TodoContext from './TodoContext';
import TodoService from './TodoService';
import TodoList from './TodoList';

function App() {
  return (
    <TodoContext.Provider value={TodoService}>
      <TodoList />
    </TodoContext.Provider>
  );
}

export default App;
```

```jsx
import React, { useState, useEffect, useContext } from 'react';
import TodoContext from './TodoContext';

function TodoList() {
  const [todos, setTodos] = useState([]);
  const todoService = useContext(TodoContext); // Retrieve TodoService from TodoContext
  useEffect(() => {
    async function fetchTodos() {
      try {
        const todos = await todoService.getTodos(); // Call TodoService from TodoContext to get todos
        setTodos(todos);
      } catch (error) {
        console.error(error);
      }
    }
    fetchTodos();
  }, [todoService]);  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  );
}
export default TodoList;
```

다음과 같은 구조로 변경하여 `TodoContext` 의 자식 컴포넌트라면 어디서든 서비스를 가져와서 사용할 수 있게 됩니다.

## IoC 컨테이너를 활용한 의존성 주입(DI)

### IoC 컨테이너란? (Inversion of Control Container)

React 에서 IoC 컨테이너는 애플리케이션의 여러 컴포넌트와 서비스 간 의존성을 관리할 수 있는 도구입니다.

서비스나 객체(의존성)를 한 번 정의하고 등록한 다음, 이를 의존하는 다른 컴포넌트에 주입하는 방법을 제공합니다. **이를 통해 컴포넌트를 분리하고 애플리케이션을 보다 모듈화하고 유지 관리하기 쉽게 만들 수 있습니다.**

React의 IoC 컨테이너는 일반적으로 종속성으로 사용할 수 있는 모든 객체를 참조하는 중앙 레지스트리를 제공하는 방식으로 작동합니다. 컴포넌트는 이러한 종속성을 직접 생성하는 대신 컨테이너에 요청할 수 있습니다. 이 접근 방식을 사용하면 종속성을 대체 구현으로 **쉽게 교체하거나 테스트를 위해 모의 구현할 수 있습니다.**

**생성자 주입, 프로퍼티 주입, 자동 종속성 해결과 같은 다양한 기능을 제공**하는 InversifyJS, Awilix, BottleJS와 같은 몇 가지 인기 있는 IoC 컨테이너를 React에 사용할 수 있습니다. **일부 IoC 컨테이너는 다른 컨테이너보다 더 복잡하므로 프로젝트의 요구 사항과 복잡성 수준에 맞는 컨테이너를 선택**하는 것이 중요합니다.

위 DI 패턴을 Context 로 구현한 예시에 IoC 컨테이너 를 적용해보면 다음과 같습니다.

```jsx
import React, { createContext, useContext } from 'react';

// Create a new context for the container
const ContainerContext = createContext();

// Define a component that provides the container to its children
const ContainerProvider = ({ container, children }) => {
  return <ContainerContext.Provider value={container}>{children}</ContainerContext.Provider>;
};

// Define a hook to access the container from within a component
const useContainer = () => {
  const container = useContext(ContainerContext);
  if (!container) {
    throw new Error('Container not found. Make sure to wrap your components with a ContainerProvider.');
  }
  return container;
};

// Define a hook to inject dependencies from the container
const useInject = (identifier) => {
  const container = useContainer();
  return container.resolve(identifier);
};

// Example usage:
const MyService = () => {
  return { foo: 'bar' };
};

const MyComponent = () => {
  const myService = useInject('myService');
  return <div>{myService.foo}</div>; // Output: 'bar'
};

const container = {
  registry: {
    myService: MyService()
  },
  resolve(identifier) {
    if (!this.registry.hasOwnProperty(identifier)) {
      throw new Error(`Object with identifier ${identifier} not found in container`);
    }
    return this.registry[identifier];
  }
};

const App = () => {
  return (
    <ContainerProvider container={container}>
      <MyComponent />
    </ContainerProvider>
  );
};
```

위 예제에서는 `ContainerContext` 를 이용하여 `useContainer` 훅을 정의하고, 

`container` 객체의 `resolve` 메서드를 이용하여 의존성을 찾고 반환하는 기능을 작성한 후 `useInject`훅을 정의하여 개발자에게 쉽게 의존성 객체를 가져올 수 있는 React 의 추상화 도구(hook) 을 제공합니다.

## 마치며

이러한 구현으로 쉽게 의존성 객체를 컨테이너 객체에 등록하고 언제든 훅으로 간편하게 가져올 수 있는 간단한 구조로 변경하여 애플리케이션의 복잡도를 낮추고 변경에 용이하게 설계할 수 있습니다.

또한 필자는 스프링 부트를 주로 다루는 개발자로서 스프링의 IoC 컨테이너 기술과 개념적으로 완전 유사한 방식을 또 React 에도 동일하게 적용하는 부분이 굉장히 흥미로웠습니다.

쉽게 변경될 수 있는 객체에 대해서 사전에 DI 를 쉽게 이용할 수 있는 패턴으로 설계해두면 복잡한 애플리케이션을 더 쉽고 빠르게 작성할 수 있을 것 같습니다.

## References

****[Dependency injection in React](https://itnext.io/dependency-injection-in-react-6fa51488509f)****