//
// Created by Diego Urgell on 15/06/21.
//


// GenericFactory for the different types of communication. Polymorphism is used so that every subclass can be handled with
// Communication pointers. The different types are stored in a map of string -> creation Method.
// The T class represents the interface which every subtype to be registered in the factory implements.

template<class T>
class GenericFactory {
protected:

    using objectCreateMethod = std::shared_ptr<T>(*)(); // Use shared pointer because the generated object is sometimes stored in a class.
    inline static std::map<std::string, objectCreateMethod> regSpecs = std::map<std::string, objectCreateMethod>();

public:

    GenericFactory<T>() = delete;

    static bool Register(const std::string name, objectCreateMethod funcCreate) {
        if (auto it = regSpecs.find(name); it == regSpecs.end()) {
            regSpecs[name] = funcCreate;
            return true;
        }
        return false;
    }

    static std::shared_ptr<T> Create(const std::string name) {
        if (auto it = regSpecs.find(name); it != regSpecs.end()) return (it->second)();
        return nullptr;
    }
};


// This helps to register classes in the Communication factory.
// Specialization, Interface, Factory
template<class S, class I, class F>
class Registration {
public:
    Registration() = delete;

    // Authomatic registration method. Specialization classes need to only provide the factoryName.
    static std::shared_ptr<I> createMethod() {
        return std::make_shared<S>();
    }

protected:
    inline static bool is_registered = F::Register(S::factoryName, S::createMethod);
};
