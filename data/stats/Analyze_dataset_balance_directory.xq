declare function local:analyze-tei-elements($context-node as node(), $namespace as xs:string) {
    let $current-dir := replace(base-uri($context-node), '[^/]+$', '')
    
    (: Collect all elements from all XML files in the directory using collection() :)
    let $all-elements := collection(concat($current-dir, '?select=*.xml'))//*[namespace-uri() = $namespace]
    
    (: Get all unique element names in alphabetical order :)
    let $unique-elements := distinct-values(
        for $el in $all-elements
        return local-name($el)
    )
    
    return
        <analysis>{
            for $element-name in $unique-elements
            let $elements := $all-elements[local-name() = $element-name]
            let $leaf-elements := $elements[not(*)]
            order by $element-name
            return
                <element>{
                    attribute name {$element-name},
                    attribute total-occurrences {count($elements)},
                    attribute leaf-occurrences {count($leaf-elements)},
                    
                    (: Analyze specific attributes with their values :)
                    let $value-attributes := ('type', 'level', 'unit', 'full', 'role'),
                    $value-analysis :=
                        for $attr in $value-attributes
                        let $elements-with-attr := $elements[@*[local-name() = $attr]]
                        where exists($elements-with-attr)
                        order by $attr
                        return
                            <attribute-values name="{$attr}">{
                                let $values := distinct-values($elements[@*[local-name() = $attr]]/@*[local-name() = $attr])
                                for $value in $values
                                order by $value
                                return
                                    <value name="{$value}" 
                                           count="{count($elements[@*[local-name() = $attr] = $value])}"/>
                            }</attribute-values>,
                            
                    (: Analyze attributes where we only count occurrences :)
                    $occurrence-attributes := ('from', 'to', 'n', 'when'),
                    $occurrence-analysis :=
                        for $attr in $occurrence-attributes
                        let $attr-count := count($elements[@*[local-name() = $attr]])
                        where $attr-count > 0
                        order by $attr
                        return
                            <attribute-occurrences name="{$attr}" count="{$attr-count}"/>
                    
                    (: Include both analyses in the output :)
                    return (
                        $value-analysis,
                        $occurrence-analysis
                    )
                }</element>
        }</analysis>
};

(: Example usage: :)
let $context := .
let $tei-namespace := 'http://www.tei-c.org/ns/1.0'
return local:analyze-tei-elements($context, $tei-namespace)
